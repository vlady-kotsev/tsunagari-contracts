// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script} from "forge-std/Script.sol";
import {GovernanceFacet} from "../src/facets/GovernanceFacet.sol";

contract DeployGovernanceFacet is Script {
    function run() external returns (GovernanceFacet) {
        vm.startBroadcast();
        GovernanceFacet governanceFacet = new GovernanceFacet();
        vm.stopBroadcast();
        return governanceFacet;
    }
}
