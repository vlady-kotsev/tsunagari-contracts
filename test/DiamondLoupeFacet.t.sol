// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test} from "forge-std/Test.sol";
import {DeployDiamond} from "../script/Diamond.deploy.s.sol";
import {IDiamond} from "../src/interfaces/IDiamond.sol";
import {Diamond} from "../src/Diamond.sol";
import {IDiamondLoupe} from "../src/interfaces/IDiamondLoupe.sol";
import {ICalculator} from "../src/interfaces/ICalculator.sol";
import {CalculatorFacet} from "../src/facets/CalculatorFacet.sol";
import {CalculatorErrors} from "../src/facets/errors/CalculatorErrors.sol";

contract DiamondLoupeTest is Test {
    IDiamond diamond;

    function setUp() public {
        DeployDiamond dd = new DeployDiamond();
        Diamond d = dd.run(true);
        diamond = IDiamond(address(d));
    }

    function testFacets() public {
        IDiamondLoupe.Facet[] memory facets = diamond.facets();

        assertEq(facets.length, 5);
        address calculatorFacetAddress = facets[facets.length - 1].facetAddress;
        ICalculator calculator = ICalculator(calculatorFacetAddress);
        vm.expectRevert(CalculatorErrors.CalculatorFacet__InvalidAmount.selector);
        calculator.calculateFee(100);
    }

    function testFacetFunctionSelectors() public view {
        IDiamondLoupe.Facet[] memory facets = diamond.facets();
        address calculatorFacetAddress = facets[facets.length - 1].facetAddress;
        bytes4[] memory selectors = diamond.facetFunctionSelectors(calculatorFacetAddress);

        assertEq(selectors.length, 4);
        assertEq(selectors[0], CalculatorFacet.getFeePercentage.selector);
    }

    function testFacetAddresses() public view {
        address[] memory addresses = diamond.facetAddresses();

        assertEq(addresses.length, 5);
    }

    function testFacetAddress() public view {
        bytes4 functionSelector = CalculatorFacet.getFeePercentage.selector;
        address facetAddress = diamond.facetAddress(functionSelector);

        IDiamondLoupe.Facet[] memory facets = diamond.facets();
        address calculatorFacetAddress = facets[facets.length - 1].facetAddress;

        assertEq(facetAddress, calculatorFacetAddress);
    }
}
