// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script, console} from "forge-std/Script.sol";
import {Diamond} from "../src/Diamond.sol";
import {CalculatorFacet} from "../src/facets/CalculatorFacet.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {IDiamond} from "../src/interfaces/IDiamond.sol";

contract InteractCalcualtorFacet is Script {
    error CalcualtorFacetInteractions__CantCallCalculatorFacet();

    function run() external {
        address diamondAddress = DevOpsTools.get_most_recent_deployment("Diamond", block.chainid);
        console.log("Latest diamond deployed at: ", diamondAddress);
        IDiamond diamond = IDiamond(diamondAddress);

        vm.startBroadcast();
        uint256 result = diamond.getFeePercentage();
        console.log("Fee percentage: ", result);
        uint256 newValue = 33;
        diamond.updateFeePercentage(newValue);
        result = diamond.getFeePercentage();
        uint256 amount = 400;
        uint256 calculatedFee = diamond.calculateFee(amount);
        vm.stopBroadcast();

        console.log("Updated Fee percentage: ", result);
        console.log("Calculated Fee :", calculatedFee);
    }
}
