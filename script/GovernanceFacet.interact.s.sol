// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {IDiamond} from "../src/interfaces/IDiamond.sol";

contract InteractGovernanceFacet is Script {
    function run() external {
        address diamondAddress = DevOpsTools.get_most_recent_deployment("Diamond", block.chainid);
        console.log("Latest diamond deployed at: ", diamondAddress);
        IDiamond diamond = IDiamond(diamondAddress);
        vm.startBroadcast();
        uint256 result = diamond.getThreshold();
        console.log("Threshold: ", result);
        uint256 newValue = 2;
        diamond.setThreshold(newValue);
        result = diamond.getThreshold();
        vm.stopBroadcast();
        console.log("Updated threshold: ", result);
    }
}
