// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/// @title LibCalculator
/// @notice A library for managing calculator storage and operations
/// @dev This library uses a specific storage slot for the calculator data
library LibCalculator {
    /// @dev Unique storage slot for calculator data
    bytes32 constant STORAGE_SLOT = keccak256("calculator.storage");

    /// @dev Structure to hold calculator storage data
    /// @param initialized Flag to check if the calculator is initialized
    /// @param feePercentage Fee percentage
    struct Storage {
        bool initialized;
        uint248 feePercentage;
    }

    /// @notice Retrieves the calculator storage
    /// @dev Uses assembly to access a specific storage slot
    /// @return ds Storage struct pointing to the calculator's storage slot
    function getCalculatorStorage() internal pure returns (Storage storage ds) {
        bytes32 position = STORAGE_SLOT;
        assembly {
            ds.slot := position
        }
    }
}
