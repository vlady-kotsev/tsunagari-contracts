// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/// @title LibTokenManager
/// @notice A library for managing token-related storage and operations
/// @dev This library uses a specific storage slot for token manager data
library LibTokenManager {
    /// @dev Unique storage slot for token manager data
    bytes32 constant STORAGE_SLOT = keccak256("token.manager.storage");

    /// @notice Structure to hold token manager storage data
    struct Storage {
        /// @notice Flag to check if the token manager is initialized
        bool initialized;
        /// @notice Minimum bridgeable amount (packed into previous storage slot)
        uint248 minBridgeableAmount;
        /// @notice Mapping to track supported tokens
        mapping(address => bool) supportedTokens;
        /// @notice Address of the treasury
        address treasuryAddress;
    }

    /// @notice Retrieves the token manager storage
    /// @dev Uses assembly to access a specific storage slot
    /// @return tms Storage struct pointing to the token manager's storage slot
    function getTokenManagerStorage() internal pure returns (Storage storage tms) {
        bytes32 position = STORAGE_SLOT;
        assembly {
            tms.slot := position
        }
    }
}
