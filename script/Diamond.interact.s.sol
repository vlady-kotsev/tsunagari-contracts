// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script, console} from "forge-std/Script.sol";
import {Diamond} from "../src/Diamond.sol";
import {CalculatorFacet} from "../src/facets/CalculatorFacet.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {IDiamond} from "../src/interfaces/IDiamond.sol";

contract InteractDiamond is Script {
    function run() external {
        address diamondAddress = DevOpsTools.get_most_recent_deployment("Diamond", block.chainid);
        address nativeTokensAddress = address(0); // update with desired token address

        IDiamond diamond = IDiamond(diamondAddress);
        vm.startBroadcast();

        diamond.lockTokens(1000000000000000000, nativeTokensAddress, block.chainid);
        console.log("Tokens locked!");

        vm.stopBroadcast();
    }
}
