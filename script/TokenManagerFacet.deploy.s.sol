// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script} from "forge-std/Script.sol";
import {TokenManagerFacet} from "../src/facets/TokenManagerFacet.sol";

contract DeployTokenManagerFacet is Script {
    function run() external returns (TokenManagerFacet) {
        vm.startBroadcast();
        TokenManagerFacet tokenManagerFacet = new TokenManagerFacet();
        vm.stopBroadcast();
        return tokenManagerFacet;
    }
}
