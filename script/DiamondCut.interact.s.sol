// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {IDiamond} from "../src/interfaces/IDiamond.sol";
import {IDiamondCut} from "../src/interfaces/IDiamondCut.sol";
import {CalculatorFacet} from "../src/facets/CalculatorFacet.sol";

contract InteractDiamondCut is Script {
    function run() external {
        string memory facetToUpdate = "CalculatorFacet";
        address diamondAddress = DevOpsTools.get_most_recent_deployment("Diamond", block.chainid);
        address facet = DevOpsTools.get_most_recent_deployment(facetToUpdate, block.chainid);
        console.log("Latest facet deployed at ", facet);

        IDiamond diamond = IDiamond(diamondAddress);

        bytes4[] memory funcSelectors = new bytes4[](1);
        funcSelectors[0] = CalculatorFacet.calculateFee.selector;
        IDiamondCut.FacetCut memory facetCut =
            IDiamondCut.FacetCut(facet, IDiamondCut.FacetCutAction.Replace, funcSelectors);
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        cuts[0] = facetCut;

        vm.startBroadcast();
        diamond.diamondCut(cuts, address(0), new bytes(0));
        vm.stopBroadcast();
    }
}
