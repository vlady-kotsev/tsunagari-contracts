// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @title LibGovernance
/// @notice A library for managing governance-related storage and operations
/// @dev This library uses a specific storage slot for governance data
library LibGovernance {
    /// @dev Unique storage slot for governance data
    bytes32 constant STORAGE_SLOT = keccak256("governance.storage");

    /// @notice Structure to hold governance storage data
    /// @dev Uses EnumerableSet for efficient member management
    struct Storage {
        /// @notice Set of addresses that are members of the governance
        EnumerableSet.AddressSet members;
        /// @notice Flag to check if the governance is initialized
        bool initialized;
        /// @notice Threshold for governance decisions (packed into previous storage slot)
        uint248 threshold;
    }

    /// @notice Retrieves the governance storage
    /// @dev Uses assembly to access a specific storage slot
    /// @return ds Storage struct pointing to the governance's storage slot
    function getGovernanceStorage() internal pure returns (Storage storage ds) {
        bytes32 position = STORAGE_SLOT;
        assembly {
            ds.slot := position
        }
    }
}
