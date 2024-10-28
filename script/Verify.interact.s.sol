// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script,console} from "forge-std/Script.sol";

import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";

contract VerifyInteract is Script {
    function run() external {
        address calculatorAddress = DevOpsTools.get_most_recent_deployment("CalculatorFacet", block.chainid);
        address governanceAddress = DevOpsTools.get_most_recent_deployment("GovernanceFacet",block.chainid);
        address tokenManagerAddress = DevOpsTools.get_most_recent_deployment("TokenManagerFacet", block.chainid);
        address diamondLoupeAddress = DevOpsTools.get_most_recent_deployment("DiamondLoupeFacet", block.chainid);
        address diamondCutAddress = DevOpsTools.get_most_recent_deployment("DiamondCutFacet", block.chainid);
        vm.startBroadcast(); 
        verifyContract(calculatorAddress, "CalculatorFacet");
        verifyContract(governanceAddress, "GovernanceFacet");
        verifyContract(tokenManagerAddress, "TokenManagerFacet");
        verifyContract(diamondLoupeAddress, "DiamondLoupeFacet");
        verifyContract(diamondCutAddress,"DiamondCutFacet");
        vm.stopBroadcast();
    }

    function verifyContract(address contractAddress, string memory contractName)
        internal
    {
        string[] memory inputs = new string[](9);
        if (block.chainid  == 80002) {
            inputs[0] = "forge";
            inputs[1] = "verify-contract";
            inputs[2] = "-e";
            inputs[3] = vm.envString("AMOY_API_KEY");
            inputs[4] = vm.toString(contractAddress);
            inputs[5] = contractName;
            inputs[6] = "--chain";
            inputs[7] = "80002";
            inputs[8] = "--watch";
        } else if (block.chainid == 167009) {
            inputs[0] = "forge";
            inputs[1] = "verify-contract";
            inputs[2] = "-e";
            inputs[3] = vm.envString("TAIKO_API_KEY");
            inputs[4] = vm.toString(contractAddress);
            inputs[5] = contractName;
            inputs[6] = "--chain";
            inputs[7] = "167009";
            inputs[8] = "--watch";
        }
        vm.ffi(inputs);
    }
}