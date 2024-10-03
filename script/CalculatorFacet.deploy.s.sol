// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script} from "forge-std/Script.sol";
import {CalculatorFacet} from "../src/facets/CalculatorFacet.sol";

contract DeployCalculatorFacet is Script {
    function run() external returns (CalculatorFacet) {
        vm.startBroadcast();
        CalculatorFacet calculatorFacet = new CalculatorFacet();
        vm.stopBroadcast();
        return calculatorFacet;
    }
}
