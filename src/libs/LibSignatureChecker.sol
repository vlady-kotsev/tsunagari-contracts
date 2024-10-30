// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {LibGovernance} from "../libs/LibGovernance.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @title LibSignatureChecker
/// @notice A library for verifying signatures and managing signature-related storage
/// @dev Uses ECDSA for signature recovery and EnumerableSet for efficient data management
library LibSignatureChecker {
    /// @dev Unique storage slot for signature checker data
    bytes32 constant STORAGE_SLOT = keccak256("signature.checker.storage");

    using ECDSA for bytes32;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    error LibSignatureChecker__InvalidSignature();
    error LibSignatureChecker__InvalidSignatureLength();
    error LibSignatureChecker__InvalidSignatures();
    error LibSignatureChecker__InvalidRecoveredAddress();
    error LibSignatureChecker__RecoveredAddressNotMember();
    error LibSignatureChecker__InvalidSignaturesCount(uint256);
    error LibSignatureChecker__InvalidSignaturesNotUnique();
    error LibSignatureChecker__InvalidMessageHashAlreadyUsed();

    /// @notice Structure to hold signature checker storage data
    struct Storage {
        /// @dev Set of unique signature hashes
        EnumerableSet.Bytes32Set uniqueSet;
        /// @dev Mapping to track used message hashes
        mapping(bytes32 => bool) usedMessageHashes;
    }

    /// @notice Retrieves the signature checker storage
    /// @return scs Storage struct pointing to the signature checker's storage slot
    function getSignatureCheckerStorage() internal pure returns (Storage storage scs) {
        bytes32 position = STORAGE_SLOT;
        assembly {
            scs.slot := position
        }
    }

    /// @notice Checks if a message hash has already been used
    /// @param messageHash The hash of the message to check
    /// @dev Reverts if the message hash has been used before
    function checkIsMessageHashAlreadyUsed(bytes32 messageHash) internal {
        Storage storage scs = getSignatureCheckerStorage();
        if (scs.usedMessageHashes[messageHash]) {
            revert LibSignatureChecker__InvalidMessageHashAlreadyUsed();
        }
        scs.usedMessageHashes[messageHash] = true;
    }

    /// @notice Checks if a signature is from a governance member
    /// @param messageHash The hash of the signed message
    /// @param signature The signature to verify
    /// @dev Reverts if the signature is invalid or not from a member
    function checkIsSignedByMember(bytes32 messageHash, bytes memory signature) internal view {
        (address recoveredAddress, ECDSA.RecoverError recoverError,) = messageHash.tryRecover(signature);
        if (recoverError != ECDSA.RecoverError.NoError) {
            bytes4 invalidSignatureSelector = LibSignatureChecker__InvalidSignature.selector;
            bytes4 invalidSignatureLengthSelector = LibSignatureChecker__InvalidSignatureLength.selector;
            bytes4 errorWrapperSelector = 0x08c379a0;

            assembly {
                let ptr := mload(0x40)
                mstore(ptr, errorWrapperSelector)
                mstore(add(0x04, ptr), 0x20)
                mstore(add(0x24, ptr), 0x4)

                switch recoverError
                case 1 { mstore(add(0x44, ptr), invalidSignatureSelector) }
                case 2 { mstore(add(0x44, ptr), invalidSignatureLengthSelector) }

                mstore(0x40, add(0x48, ptr))
                revert(ptr, 0x48)
            }
        }

        LibGovernance.Storage storage gs = LibGovernance.getGovernanceStorage();

        bool isMember = gs.members.contains(recoveredAddress);
        if (!isMember) {
            revert LibSignatureChecker__RecoveredAddressNotMember();
        }
    }

    /// @notice Checks the uniqueness and count of signatures
    /// @param signatures Array of signatures to check
    /// @dev Reverts if the number of signatures doesn't match the threshold or if signatures are not unique
    function checkSignaturesUniquenessAndCount(bytes[] memory signatures) internal {
        LibGovernance.Storage storage gs = LibGovernance.getGovernanceStorage();
        if (signatures.length < gs.threshold) {
            revert LibSignatureChecker__InvalidSignaturesCount(signatures.length);
        }
        Storage storage sgs = getSignatureCheckerStorage();
        for (uint256 i = 0; i < gs.threshold;) {
            bool isUnique = sgs.uniqueSet.add(keccak256(signatures[i]));
            if (!isUnique) {
                revert LibSignatureChecker__InvalidSignaturesNotUnique();
            }

            assembly {
                i := add(1, i)
            }
        }
    }

    /// @notice Gets the Ethereum prefixed hash of a message
    /// @param rawMessage The raw message to hash
    /// @return The Ethereum prefixed hash of the message
    function getPrefixedHash(bytes memory rawMessage) internal pure returns (bytes32) {
        bytes memory prefix = abi.encodePacked("\x19Ethereum Signed Message:\n", uint2str(rawMessage.length));

        bytes memory prefixedMessage = abi.encodePacked(prefix, rawMessage);

        return keccak256(prefixedMessage);
    }

    /// @notice Converts a uint256 to a string
    /// @param _i The uint256 to convert
    /// @return _uintAsString The string representation of the uint256
    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            bstr[--k] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}
