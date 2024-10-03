// SPDX-License-Identifier: MIT 
pragma solidity 0.8.23;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {IWrappedToken} from "../src/interfaces/IWrappedToken.sol";

contract MintWrappedToken is Script{

    function run() external {
        address diamondAddress = DevOpsTools.get_most_recent_deployment("Diamond", block.chainid);
        address wrappedTokenAddress = DevOpsTools.get_most_recent_deployment("WrappedToken", block.chainid);
        
        vm.startBroadcast(diamondAddress);
        IWrappedToken wrappedToken = IWrappedToken(wrappedTokenAddress);
        wrappedToken.mint(diamondAddress, 10000);
        vm.stopBroadcast();
    }
    

    
}
