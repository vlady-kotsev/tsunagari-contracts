// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test} from "forge-std/Test.sol";
import {DeployDiamond} from "../../script/Diamond.deploy.s.sol";
import {IDiamond} from "../../src/interfaces/IDiamond.sol";
import {Diamond} from "../../src/Diamond.sol";

contract DiamondLoupeFuzzTest is Test {
    IDiamond diamond;

    function setUp() public {
        DeployDiamond dd = new DeployDiamond();
        Diamond d = dd.run(true);
        diamond = IDiamond(address(d));
    }

    function testFuzzFacetAddressDoesntRevert(bytes4 functionSelector) public view {
        diamond.facetAddress(functionSelector);
    }

    function testFuzzFacetFunctionSelectorsDoesntRevert(address facetAddress) public view {
        diamond.facetFunctionSelectors(facetAddress);
    }
}
