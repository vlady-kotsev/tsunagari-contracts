// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/// @title ITokenManager
/// @notice Interface for managing token operations in a bridge system
/// @dev This interface defines functions for locking, unlocking, minting, and burning tokens, as well as managing bridge parameters
interface ITokenManager {
    /// @notice Initializes the token manager with minimum bridgeable amount and treasury address
    /// @param minBridgeableAmount The minimum amount of tokens that can be bridged
    /// @param treasuryAddress The address of the treasury
    function initTokenManager(uint248 minBridgeableAmount, address treasuryAddress) external;

    /// @notice Locks tokens in the contract
    /// @param amount The amount of tokens to lock
    /// @param tokenAddress The address of the token to lock
    function lockTokens(uint256 amount, address tokenAddress) external;

    /// @notice Unlocks tokens and transfers them to a specified address
    /// @param amount The amount of tokens to unlock
    /// @param to The address to receive the unlocked tokens
    /// @param tokenAddress The address of the token to unlock
    /// @param message The message that was signed by the authorized parties
    /// @param signatures An array of signatures from the authorized parties
    function unlockTokens(
        uint256 amount,
        address to,
        address tokenAddress,
        bytes memory message,
        bytes[] memory signatures
    ) external;

    /// @notice Mints wrapped tokens to a specified address
    /// @param amount The amount of wrapped tokens to mint
    /// @param to The address to receive the minted tokens
    /// @param wrappedTokenAddress The address of the wrapped token to mint
    /// @param message The message that was signed by the authorized parties
    /// @param signatures An array of signatures from the authorized parties
    function mintWrappedTokens(
        uint256 amount,
        address to,
        address wrappedTokenAddress,
        bytes memory message,
        bytes[] memory signatures
    ) external;

    /// @notice Burns wrapped tokens
    /// @param amount The amount of wrapped tokens to burn
    /// @param tokenAddress The address of the wrapped token to burn
    function burnWrappedToken(uint256 amount, address tokenAddress) external;

    /// @notice Retrieves the minimum bridgeable amount
    /// @return The minimum amount of tokens that can be bridged
    function getMinimumBridgeableAmount() external returns (uint256);

    /// @notice Sets a new minimum bridgeable amount
    /// @param amount The new minimum bridgeable amount
    /// @param message The message that was signed by the authorized parties
    /// @param signatures An array of signatures from the authorized parties
    function setMinimumBridgeableAmount(uint248 amount, bytes memory message, bytes[] memory signatures) external;

    /// @notice Adds a new token to the list of supported tokens
    /// @param tokenAddress The address of the token to add
    /// @param message The message that was signed by the authorized parties
    /// @param signatures An array of signatures from the authorized parties
    function addNewSupportedToken(address tokenAddress, bytes memory message, bytes[] memory signatures) external;

    /// @notice Withdraws token funds to the treasury
    /// @param tokenAddress The address of the token to withdraw
    function withdrawTokenFunds(address tokenAddress) external;

    /// @notice Retrieves the treasury address
    /// @param message The message that was signed by the authorized parties
    /// @param signatures An array of signatures from the authorized parties
    /// @return The address of the treasury
    function getTreasuryAddress(bytes memory message, bytes[] memory signatures) external returns (address);

    /// @notice Sets a new treasury address
    /// @param treasuryAddress The new treasury address
    /// @param message The message that was signed by the authorized parties
    /// @param signatures An array of signatures from the authorized parties
    function setTreasuryAddress(address treasuryAddress, bytes memory message, bytes[] memory signatures) external;

    /// @notice Checks if a token is supported
    /// @param tokenAddress The address of the token to check
    /// @return A boolean indicating whether the token is supported
    function isTokenSupported(address tokenAddress) external returns (bool);
}
