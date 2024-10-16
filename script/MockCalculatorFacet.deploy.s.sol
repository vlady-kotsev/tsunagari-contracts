// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script} from "forge-std/Script.sol";
import {MockCalculatorFacet} from "../test/mocks/MockTokenCalculatorFacet.sol";

contract DeployMockCalculatorFacet is Script {
    function run() external returns (MockCalculatorFacet) {
        vm.startBroadcast();
        MockCalculatorFacet calculatorFacet = new MockCalculatorFacet();
        vm.stopBroadcast();
        return calculatorFacet;
    }
}
