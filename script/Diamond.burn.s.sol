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
        address wrappedTokensAddress = address(0); // update with desired token address

        IDiamond diamond = IDiamond(diamondAddress);
        vm.startBroadcast();

        diamond.burnWrappedToken(1000000000000000000, wrappedTokensAddress, 80002);
        console.log("Tokens burned!");

        vm.stopBroadcast();
    }
}
