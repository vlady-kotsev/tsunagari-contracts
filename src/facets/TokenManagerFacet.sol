// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IWrappedToken, IERC20} from "../interfaces/IWrappedToken.sol";
import {SignatureChecker} from "../utils/SignatureChecker.sol";
import {ITokenManager} from "../interfaces/ITokenManager.sol";
import {IDiamond} from "../interfaces/IDiamond.sol";
import {LibTokenManager} from "../libs/LibTokenManager.sol";
import {SafeERC20} from "@openzeppelincontracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenManagerFacet is SignatureChecker, ITokenManager {
    using SafeERC20 for IERC20;
    using SafeERC20 for IWrappedToken;

    error TokenManager__InvalidLockAmount();
    error TokenManager__InvalidMintAmount();
    error TokenManager__InvalidWrappedTokenAddress();
    error TokenManager__InvalidMintReceiverAddress();
    error TokenManager__InvalidBurnAmount();
    error TokenManager__InvalidBurnTokenAddress();
    error TokenManager__InvalidUnlockAmount();
    error TokenManager__InvalidUnlockReceiverAddress();
    error TokenManager__InvalidMinBridgeableAmount();
    error TokenManager__FacetAlreadyInitialized();
    error TokenManager__TokenAlreadyAdded(address);
    error TokenManager__TokenNotSupported(address);

    event TokensLocked(address indexed user, address indexed tokenAddress, uint256 amount);
    event WrappedTokensMinted(address indexed to, address indexed wrappedTokenAddress, uint256 amount);
    event WrappedTokensBurned(address indexed user, address indexed tokenAddress, uint256 amount);
    event TokensUnlocked(address indexed user, address indexed tokenAddress, uint256 amount);
    event MinBridgeableAmountUpdated(uint256 amount);

    function initTokenManager(uint256 minBridgeableAmount) external {
        LibTokenManager.Storage storage tms = LibTokenManager.getTokenManagerStorage();
        if (tms.initialized) {
            revert TokenManager__FacetAlreadyInitialized();
        }
        if (minBridgeableAmount == 0) {
            revert TokenManager__InvalidMinBridgeableAmount();
        }

        tms.initialized = true;
        tms.minBridgeableAmount = minBridgeableAmount;
    }

    function lockTokens(uint256 amount, address tokenAddress) external enforceSupportedToken(tokenAddress) {
        if (amount == 0) {
            revert TokenManager__InvalidLockAmount();
        }

        IERC20 token = IERC20(tokenAddress);
        token.safeTransferFrom(msg.sender, address(this), amount);

        uint256 calculatedAfterFee = amount - IDiamond(address(this)).calculateFee(amount);

        emit TokensLocked(msg.sender, tokenAddress, calculatedAfterFee);
    }

    function mintWrappedTokens(
        uint256 amount,
        address to,
        address wrappedTokenAddress,
        bytes32 messageHash,
        bytes[] memory signatures
    ) external enforceIsSignedByAllMembers(messageHash, signatures) enforceSupportedToken(wrappedTokenAddress) {
        if (to == address(0)) {
            revert TokenManager__InvalidMintReceiverAddress();
        }
        if (amount == 0) {
            revert TokenManager__InvalidMintAmount();
        }
        if (wrappedTokenAddress == address(0)) {
            revert TokenManager__InvalidWrappedTokenAddress();
        }

        IWrappedToken token = IWrappedToken(wrappedTokenAddress);
        token.mint(to, amount);

        emit WrappedTokensMinted(to, wrappedTokenAddress, amount);
    }

    function burnWrappedToken(uint256 amount, address wrappedTokenAddress)
        external
        enforceSupportedToken(wrappedTokenAddress)
    {
        if (amount == 0) {
            revert TokenManager__InvalidBurnAmount();
        }
        if (wrappedTokenAddress == address(0)) {
            revert TokenManager__InvalidBurnTokenAddress();
        }

        IWrappedToken token = IWrappedToken(wrappedTokenAddress);
        token.burnFrom(msg.sender, amount);

        emit WrappedTokensBurned(msg.sender, wrappedTokenAddress, amount);
    }

    function unlockTokens(
        uint256 amount,
        address to,
        address tokenAddress,
        bytes32 messageHash,
        bytes[] memory signatures
    ) external enforceIsSignedByAllMembers(messageHash, signatures) enforceSupportedToken(tokenAddress) {
        if (amount == 0) {
            revert TokenManager__InvalidUnlockAmount();
        }
        if (to == address(0)) {
            revert TokenManager__InvalidUnlockReceiverAddress();
        }
        if (tokenAddress == address(0)) {
            revert TokenManager__InvalidWrappedTokenAddress();
        }

        uint256 calculatedAfterFee = amount - IDiamond(address(this)).calculateFee(amount);

        IERC20 token = IERC20(tokenAddress);
        token.safeTransfer(to, calculatedAfterFee);

        emit TokensUnlocked(to, tokenAddress, calculatedAfterFee);
    }

    function getMinimumBridgeableAmount() external view returns (uint256) {
        LibTokenManager.Storage storage tms = LibTokenManager.getTokenManagerStorage();
        return tms.minBridgeableAmount;
    }

    function setMinimumBridgeableAmount(uint256 amount, bytes32 messageHash, bytes[] memory signatures)
        external
        enforceIsSignedByAllMembers(messageHash, signatures)
    {
        if (amount == 0) {
            revert TokenManager__InvalidMinBridgeableAmount();
        }
        LibTokenManager.Storage storage tms = LibTokenManager.getTokenManagerStorage();
        tms.minBridgeableAmount = amount;

        emit MinBridgeableAmountUpdated(amount);
    }

    function addNewSupportedToken(address tokenAddress, bytes32 messageHash, bytes[] memory signatures)
        external
        enforceIsSignedByAllMembers(messageHash, signatures)
    {
        LibTokenManager.Storage storage tms = LibTokenManager.getTokenManagerStorage();

        if (tms.supportedTokens[tokenAddress]) {
            revert TokenManager__TokenAlreadyAdded(tokenAddress);
        }
        tms.supportedTokens[tokenAddress] = true;
    }

    modifier enforceSupportedToken(address tokenAddress) {
        LibTokenManager.Storage storage tms = LibTokenManager.getTokenManagerStorage();
        if (!tms.supportedTokens[tokenAddress]) {
            revert TokenManager__TokenNotSupported(tokenAddress);
        }
        _;
    }
}
