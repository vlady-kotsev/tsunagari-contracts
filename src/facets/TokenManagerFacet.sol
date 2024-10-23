// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IWrappedToken, IERC20} from "../interfaces/IWrappedToken.sol";
import {SignatureChecker} from "../utils/SignatureChecker.sol";
import {ITokenManager} from "../interfaces/ITokenManager.sol";
import {IDiamond} from "../interfaces/IDiamond.sol";
import {LibTokenManager} from "../libs/LibTokenManager.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {LibTokenManagerErrors} from "./errors/LibTokenManagerErrors.sol";

/// @title TokenManagerFacet
/// @notice Manages token operations including locking, unlocking, minting, and burning of wrapped tokens
/// @dev Implements the ITokenManager interface and uses the Diamond pattern for upgradability
contract TokenManagerFacet is SignatureChecker, ITokenManager {
    using SafeERC20 for IERC20;
    using SafeERC20 for IWrappedToken;

    event TokensLocked(address indexed user, address indexed tokenAddress, uint256 amount);
    event WrappedTokensMinted(address indexed to, address indexed wrappedTokenAddress, uint256 amount);
    event WrappedTokensBurned(address indexed user, address indexed tokenAddress, uint256 amount);
    event TokensUnlocked(address indexed user, address indexed tokenAddress, uint256 amount);
    event MinBridgeableAmountUpdated(uint256 amount);
    event TreasuryAddressUpdated();
    event TokenFundsWithdrawnToTreasury(address);

    /// @notice Initializes the TokenManager with minimum bridgeable amount and treasury address
    /// @param minBridgeableAmount The minimum amount that can be bridged
    /// @param treasuryAddress The address of the treasury
    function initTokenManager(uint248 minBridgeableAmount, address treasuryAddress) external {
        LibTokenManager.Storage storage tms = LibTokenManager.getTokenManagerStorage();
        if (tms.initialized) {
            revert LibTokenManagerErrors.TokenManager__FacetAlreadyInitialized();
        }
        if (minBridgeableAmount == 0) {
            revert LibTokenManagerErrors.TokenManager__InvalidMinBridgeableAmount();
        }
        if (treasuryAddress == address(0)) {
            revert LibTokenManagerErrors.TokenManager__InvalidTreasuryAddress();
        }

        tms.initialized = true;
        tms.minBridgeableAmount = minBridgeableAmount;
        tms.treasuryAddress = treasuryAddress;
    }

    /// @notice Locks tokens in the contract
    /// @param amount The amount of tokens to lock
    /// @param tokenAddress The address of the token to lock
    /// @dev Emits a TokensLocked event
    function lockTokens(uint256 amount, address tokenAddress)
        external
        enforceSupportedToken(tokenAddress)
        enforceAboveMinBridgeableAmount(amount)
    {
        IERC20 token = IERC20(tokenAddress);
        token.safeTransferFrom(msg.sender, address(this), amount);

        uint256 calculatedAfterFee = amount - IDiamond(address(this)).calculateFee(amount);

        emit TokensLocked(msg.sender, tokenAddress, calculatedAfterFee);
    }

    /// @notice Mints wrapped tokens
    /// @param amount The amount of wrapped tokens to mint
    /// @param to The address to receive the minted tokens
    /// @param wrappedTokenAddress The address of the wrapped token
    /// @param message The message to be signed
    /// @param signatures The signatures of the validators
    /// @dev Emits a WrappedTokensMinted event
    function mintWrappedTokens(
        uint256 amount,
        address to,
        address wrappedTokenAddress,
        bytes memory message,
        bytes[] memory signatures
    ) external enforceIsSignedByAllMembers(message, signatures) enforceSupportedToken(wrappedTokenAddress) {
        if (to == address(0)) {
            revert LibTokenManagerErrors.TokenManager__InvalidMintReceiverAddress();
        }
        if (amount == 0) {
            revert LibTokenManagerErrors.TokenManager__InvalidMintAmount();
        }
        IWrappedToken token = IWrappedToken(wrappedTokenAddress);
        token.mint(to, amount);

        emit WrappedTokensMinted(to, wrappedTokenAddress, amount);
    }

    /// @notice Burns wrapped tokens
    /// @param amount The amount of wrapped tokens to burn
    /// @param wrappedTokenAddress The address of the wrapped token
    /// @dev Emits a WrappedTokensBurned event
    function burnWrappedToken(uint256 amount, address wrappedTokenAddress)
        external
        enforceSupportedToken(wrappedTokenAddress)
        enforceAboveMinBridgeableAmount(amount)
    {
        IWrappedToken token = IWrappedToken(wrappedTokenAddress);
        token.burnFrom(msg.sender, amount);

        emit WrappedTokensBurned(msg.sender, wrappedTokenAddress, amount);
    }

    /// @notice Unlocks tokens and transfers them to the specified address
    /// @param amount The amount of tokens to unlock
    /// @param to The address to receive the unlocked tokens
    /// @param tokenAddress The address of the token to unlock
    /// @param message The message to be signed
    /// @param signatures The signatures of the validators
    /// @dev Emits a TokensUnlocked event
    function unlockTokens(
        uint256 amount,
        address to,
        address tokenAddress,
        bytes memory message,
        bytes[] memory signatures
    ) external enforceIsSignedByAllMembers(message, signatures) enforceSupportedToken(tokenAddress) {
        if (amount == 0) {
            revert LibTokenManagerErrors.TokenManager__InvalidUnlockAmount();
        }
        if (to == address(0)) {
            revert LibTokenManagerErrors.TokenManager__InvalidUnlockReceiverAddress();
        }

        uint256 calculatedAfterFee = amount - IDiamond(address(this)).calculateFee(amount);

        IERC20 token = IERC20(tokenAddress);
        token.safeTransfer(to, calculatedAfterFee);

        emit TokensUnlocked(to, tokenAddress, calculatedAfterFee);
    }

    /// @notice Returns the minimum bridgeable amount
    /// @dev Can be called by anyone
    function getMinimumBridgeableAmount() external view returns (uint256) {
        LibTokenManager.Storage storage tms = LibTokenManager.getTokenManagerStorage();
        return tms.minBridgeableAmount;
    }

    /// @notice Sets the minimum bridgeable amount
    /// @param amount The new minimum bridgeable amount
    /// @param message The message to be signed
    /// @param signatures The signatures of the validators
    /// @dev Emits a MinBridgeableAmountUpdated event
    function setMinimumBridgeableAmount(uint248 amount, bytes memory message, bytes[] memory signatures)
        external
        enforceIsSignedByAllMembers(message, signatures)
    {
        if (amount == 0) {
            revert LibTokenManagerErrors.TokenManager__InvalidMinBridgeableAmount();
        }
        LibTokenManager.Storage storage tms = LibTokenManager.getTokenManagerStorage();
        tms.minBridgeableAmount = amount;

        emit MinBridgeableAmountUpdated(amount);
    }

    /// @notice Adds a new supported token
    /// @param tokenAddress The address of the token to add
    /// @param message The message to be signed
    /// @param signatures The signatures of the validators
    /// @dev Can only be called by the validators
    function addNewSupportedToken(address tokenAddress, bytes memory message, bytes[] memory signatures)
        external
        enforceIsSignedByAllMembers(message, signatures)
    {
        LibTokenManager.Storage storage tms = LibTokenManager.getTokenManagerStorage();

        if (tms.supportedTokens[tokenAddress]) {
            revert LibTokenManagerErrors.TokenManager__TokenAlreadyAdded();
        }
        tms.supportedTokens[tokenAddress] = true;
    }

    /// @notice Sets the treasury address
    /// @param treasuryAddress The new treasury address
    /// @param message The message to be signed
    /// @param signatures The signatures of the validators
    /// @dev Can only be called by the validators
    function setTreasuryAddress(address treasuryAddress, bytes memory message, bytes[] memory signatures)
        external
        enforceIsSignedByAllMembers(message, signatures)
    {
        if (treasuryAddress == address(0)) {
            revert LibTokenManagerErrors.TokenManager__InvalidTreasuryAddress();
        }
        LibTokenManager.Storage storage tms = LibTokenManager.getTokenManagerStorage();
        tms.treasuryAddress = treasuryAddress;
        emit TreasuryAddressUpdated();
    }

    /// @notice Withdraws token funds from the contract
    /// @param tokenAddress The address of the token to withdraw
    /// @dev Can only be called by the validators
    function withdrawTokenFunds(address tokenAddress) external enforceSupportedToken(tokenAddress) {
        LibTokenManager.Storage storage tms = LibTokenManager.getTokenManagerStorage();
        IWrappedToken token = IWrappedToken(tokenAddress);
        uint256 acumulatedBalance = token.balanceOf(address(this));
        token.safeTransfer(tms.treasuryAddress, acumulatedBalance);
        emit TokenFundsWithdrawnToTreasury(tokenAddress);
    }

    /// @notice Checks if a token is supported
    /// @param tokenAddress The address of the token to check
    /// @dev Can be called by anyone
    function isTokenSupported(address tokenAddress) external view returns (bool) {
        LibTokenManager.Storage storage tms = LibTokenManager.getTokenManagerStorage();
        return tms.supportedTokens[tokenAddress];
    }

    /// @notice Returns the treasury address
    /// @param message The message to be signed
    /// @param signatures The signatures of the validators
    /// @dev Can only be called by the validators
    function getTreasuryAddress(bytes memory message, bytes[] memory signatures)
        external
        enforceIsSignedByAllMembers(message, signatures)
        returns (address)
    {
        LibTokenManager.Storage storage tms = LibTokenManager.getTokenManagerStorage();
        return tms.treasuryAddress;
    }

    /// @notice Ensures that the given token is supported
    /// @param tokenAddress The address of the token to check
    /// @dev Reverts with TokenManager__TokenNotSupported if the token is not supported
    modifier enforceSupportedToken(address tokenAddress) {
        LibTokenManager.Storage storage tms = LibTokenManager.getTokenManagerStorage();
        if (!tms.supportedTokens[tokenAddress]) {
            revert LibTokenManagerErrors.TokenManager__TokenNotSupported(tokenAddress);
        }
        _;
    }

    /// @notice Ensures that the given amount is above the minimum bridgeable amount
    /// @param amount The amount to check
    /// @dev Reverts with TokenManager__InvalidTransferAmount if the amount is below the minimum
    modifier enforceAboveMinBridgeableAmount(uint256 amount) {
        LibTokenManager.Storage storage tms = LibTokenManager.getTokenManagerStorage();
        if (amount < tms.minBridgeableAmount) {
            revert LibTokenManagerErrors.TokenManager__InvalidTransferAmount(amount);
        }
        _;
    }
}
