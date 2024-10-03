// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

library LibTokenManager {
    bytes32 constant STORAGE_SLOT = keccak256("token.manager.storega");

    struct Storage {
        bool initialized;
        uint256 minBridgeableAmount;
        mapping (address => bool) supportedTokens;
    }

    function getTokenManagerStorage() internal pure returns (Storage storage tms) {
        bytes32 position = STORAGE_SLOT;
        assembly {
            tms.slot := position
        }
    }
}
