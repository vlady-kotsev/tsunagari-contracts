// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibSignatureChecker} from "../libs/LibSignatureChecker.sol";

contract SignatureChecker {
    modifier enforceIsSignedByAllMembers(bytes32 messageHash, bytes[] memory signatures) {
        LibSignatureChecker.checkIsMessageHashAlreadyUsed(messageHash);

        LibSignatureChecker.checkSignaturesUniquenessAndCount(signatures);

        for (uint256 i = 0; i < signatures.length;) {
            LibSignatureChecker.checkIsSignedByMember(messageHash, signatures[i]);
        }
        _;
    }
}
