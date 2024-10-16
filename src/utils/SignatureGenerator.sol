// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibSignatureChecker} from "../libs/LibSignatureChecker.sol";
import {Test} from "forge-std/Test.sol";

contract SignatureGenerator is Test {
    bytes[] signatures;
    string message;
    bytes messageWithNonce;
    uint256 privateKey;
    uint256 nonce;

    function initSignatureGenerator(uint256 threshold) internal {
        nonce = 0;
        privateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        message = "Hello, Ethereum!";
        signatures = new bytes[](threshold);
    }

    function getSignature() internal view returns (bytes memory) {
        string memory noncedMessage = getNoncedeMessage();

        bytes32 messageHash = LibSignatureChecker.getPrefixedHash(bytes(noncedMessage));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);
        return abi.encodePacked(r, s, v);
    }

    function getNoncedeMessage() internal view returns (string memory) {
        return string(abi.encodePacked(message, LibSignatureChecker.uint2str(nonce)));
    }

    function getUniqueSignature() internal returns (bytes memory) {
        nonce++;
        signatures[0] = getSignature();
        return bytes(getNoncedeMessage());
    }
}
