// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibSignatureChecker} from "../libs/LibSignatureChecker.sol";

contract SignatureChecker {
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
