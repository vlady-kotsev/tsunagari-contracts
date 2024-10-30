// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {IDiamond} from "../src/interfaces/IDiamond.sol";
import {SignatureGenerator} from "../src/utils/SignatureGenerator.sol";

contract InteractTokenManagerFacet is Script, SignatureGenerator {
    function run() external {
        address newTokenAddress = address(0); // update with desired token address
        address diamondAddress = DevOpsTools.get_most_recent_deployment("Diamond", block.chainid);

        IDiamond diamond = IDiamond(diamondAddress);
        initSignatureGenerator(diamond.getThreshold());
        // update nonce, to be create random message
        messageWithNonce = getUniqueSignature(1);
        vm.startBroadcast();

        diamond.addNewSupportedToken(newTokenAddress, messageWithNonce, signatures);

        vm.stopBroadcast();
        console.log("New token added successfully");
    }
}
