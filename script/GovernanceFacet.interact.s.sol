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

        uint256 threshold = diamond.getThreshold();
        console.log("Threshold: ", threshold);

        vm.stopBroadcast();
    }
}
