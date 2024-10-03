// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library LibGovernance {
    bytes32 constant STORAGE_SLOT = keccak256("governance.storage");

    struct Storage {
        bool initialized;
        EnumerableSet.AddressSet members;
        uint256 threshold;
    }

    function getGovernanceStorage() internal pure returns (Storage storage ds) {
        bytes32 position = STORAGE_SLOT;
        assembly {
            ds.slot := position
        }
    }
}