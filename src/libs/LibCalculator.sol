// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

library LibCalculator {
    bytes32 constant STORAGE_SLOT = keccak256("calculator.storage");

    // one storage slot
    struct Storage {
        bool initialized;
        uint248 feePercentage; // 5% = 500
    }

    function getCalculatorStorage() internal pure returns (Storage storage ds) {
        bytes32 position = STORAGE_SLOT;
        assembly {
            ds.slot := position
        }
    }
}
