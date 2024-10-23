// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibSignatureChecker} from "../libs/LibSignatureChecker.sol";
import {Test} from "forge-std/Test.sol";

/// @title SignatureGenerator
/// @notice A contract for generating signatures in tests
/// @dev This contract is used for testing purposes only
contract SignatureGenerator is Test {
    /// @dev Array to store generated signatures
    bytes[] signatures;
    /// @dev Message to be signed
    string message;
    /// @dev Message with nonce
    bytes messageWithNonce;
    /// @dev Private key used for signing (hardcoded for testing)
    uint256 privateKey;
    /// @dev Nonce for generating unique message hashes
    uint256 nonce;

    /// @notice Initializes the SignatureGenerator with a given threshold
    /// @param threshold The number of signatures to generate
    /// @dev Sets up initial values for testing, including a hardcoded private key
    function initSignatureGenerator(uint256 threshold) internal {
        nonce = 0;
        privateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        message = "Hello, Ethereum!";
        signatures = new bytes[](threshold);
    }

    /// @notice Generates a signature for the current message and nonce
    /// @return The generated signature
    /// @dev Uses the vm.sign function from forge-std for signing
    function getSignature() internal view returns (bytes memory) {
        string memory noncedMessage = getNoncedeMessage();

        bytes32 messageHash = LibSignatureChecker.getPrefixedHash(bytes(noncedMessage));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);
        return abi.encodePacked(r, s, v);
    }

    /// @notice Gets the current message with the nonce appended
    /// @return The nonced message as a string
    function getNoncedeMessage() internal view returns (string memory) {
        return string(abi.encodePacked(message, LibSignatureChecker.uint2str(nonce)));
    }

    /// @notice Generates a unique signature by incrementing the nonce
    /// @return The nonced message as bytes
    /// @dev This function increments the nonce and stores the new signature
    function getUniqueSignature() internal returns (bytes memory) {
        nonce++;
        signatures[0] = getSignature();
        return bytes(getNoncedeMessage());
    }
}
