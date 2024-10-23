// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibSignatureChecker} from "../libs/LibSignatureChecker.sol";

/// @title SignatureChecker
/// @notice A contract that provides signature verification functionality
/// @dev Uses LibSignatureChecker for signature validation
contract SignatureChecker {
    /// @notice Modifier to enforce that a message is signed by all required members
    /// @param message The message that was signed
    /// @param signatures Array of signatures to verify
    /// @dev This modifier performs several checks:
    ///      1. Calculates the message hash
    ///      2. Checks if the message hash has been used before
    ///      3. Verifies the uniqueness and count of signatures
    ///      4. Checks each signature against the message hash
    modifier enforceIsSignedByAllMembers(bytes memory message, bytes[] memory signatures) {
        bytes32 messageHash = LibSignatureChecker.getPrefixedHash(message);

        LibSignatureChecker.checkIsMessageHashAlreadyUsed(messageHash);

        LibSignatureChecker.checkSignaturesUniquenessAndCount(signatures);

        for (uint256 i = 0; i < signatures.length;) {
            LibSignatureChecker.checkIsSignedByMember(messageHash, signatures[i]);

            assembly {
                i := add(i, 1)
            }
        }
        _;
    }
}
