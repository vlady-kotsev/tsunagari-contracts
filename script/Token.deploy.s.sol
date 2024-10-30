// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script} from "forge-std/Script.sol";
import {NativeToken} from "../test/mocks/NativeToken.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";

contract DeployToken is Script {
    function run() external returns (NativeToken) {
        vm.startBroadcast();
        NativeToken nt = new NativeToken("AmoyNativeToken", "ANT");
        vm.stopBroadcast();
        return nt;
    }
}
