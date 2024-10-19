// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

library LibTokenManager {
    bytes32 constant STORAGE_SLOT = keccak256("token.manager.storega");

    struct Storage {
        bool initialized;
        uint248 minBridgeableAmount; // in order to fit in previous storage slot
        mapping(address => bool) supportedTokens;
        address treasuryAddress;
    }

    function getTokenManagerStorage() internal pure returns (Storage storage tms) {
        bytes32 position = STORAGE_SLOT;
        assembly {
            tms.slot := position
        }
    }
}
