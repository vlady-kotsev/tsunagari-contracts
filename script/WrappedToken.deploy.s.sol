// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script} from "forge-std/Script.sol";
import {WrappedToken} from "../src/WrappedToken.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";

contract DeployWrappedToken is Script {
    function run() external returns (WrappedToken) {
        address diamondAddress = DevOpsTools.get_most_recent_deployment("Diamond", block.chainid);
        vm.startBroadcast();
        WrappedToken wt = new WrappedToken(diamondAddress, "WrappedTaikoNativeToken", "WTNT");
        vm.stopBroadcast();
        return wt;
    }
}
