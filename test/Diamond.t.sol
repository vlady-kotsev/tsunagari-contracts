// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test} from "forge-std/Test.sol";
import {Diamond} from "../src/Diamond.sol";
import {IDiamondCut} from "../src/interfaces/IDiamondCut.sol";
import {LibDiamond} from "../src/libs/LibDiamond.sol";
import {DiamondCutFacet} from "../src/facets/DiamondCutFacet.sol";
import {DeployDiamondCutFacet} from "../script/DiamondCutFacet.deploy.s.sol";
import {IDiamond} from "../src/interfaces/IDiamond.sol";

contract DiamondTest is Test {
    Diamond diamond;
    DiamondCutFacet diamondCutFacet;

    function testDiamondConstructor() public {
        DeployDiamondCutFacet ddcf = new DeployDiamondCutFacet();
        diamondCutFacet = ddcf.run();

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory facetSelectors = new bytes4[](1);
        facetSelectors[0] = DiamondCutFacet.diamondCut.selector;
        cuts[0] = IDiamondCut.FacetCut(address(diamondCutFacet), IDiamondCut.FacetCutAction.Add, facetSelectors);

        diamond = new Diamond(cuts);

        IDiamond idiamond = IDiamond(address(diamond));
        cuts[0] = IDiamondCut.FacetCut(address(diamondCutFacet), IDiamondCut.FacetCutAction.Remove, facetSelectors);
        idiamond.diamondCut(cuts, address(0), new bytes(0));
    }
}
