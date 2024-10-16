// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script} from "forge-std/Script.sol";
import {DiamondCutFacet} from "../src/facets/DiamondCutFacet.sol";

contract DeployDiamondCutFacet is Script {
    function run() external returns (DiamondCutFacet) {
        vm.startBroadcast();
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        vm.stopBroadcast();
        return diamondCutFacet;
    }
}
