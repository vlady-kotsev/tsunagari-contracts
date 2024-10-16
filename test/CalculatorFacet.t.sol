// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {CalculatorFacet} from "../src/facets/CalculatorFacet.sol";
import {LibCalculator} from "../src/libs/LibCalculator.sol";
import {DeployCalculatorFacet} from "../script/CalculatorFacet.deploy.s.sol";

contract CalculatorFacetTest is Test {
    CalculatorFacet calculatorFacet;

    function setUp() public {
        DeployCalculatorFacet dcf = new DeployCalculatorFacet();
        calculatorFacet = dcf.run();
    }

    function testInitCalculator() public {
        calculatorFacet.initCalculator();

        assertEq(calculatorFacet.getFeePercentage(), 500);
        vm.expectRevert(CalculatorFacet.CalculatorFacet__FacetAlreadyInitialized.selector);
        calculatorFacet.initCalculator();
    }

    function testGetFeePercentage() public {
        calculatorFacet.initCalculator();

        uint256 feePercentage = calculatorFacet.getFeePercentage();
        assertEq(feePercentage, 500);
    }

    function testUpdateFeePercentage() public {
        calculatorFacet.initCalculator();

        calculatorFacet.updateFeePercentage(1000);

        uint256 updatedFee = calculatorFacet.getFeePercentage();
        assertEq(updatedFee, 1000);

        vm.expectRevert(CalculatorFacet.CalculatorFacet__InvalidFeePercentage.selector);
        calculatorFacet.updateFeePercentage(10001);

        vm.expectRevert(CalculatorFacet.CalculatorFacet__InvalidFeePercentage.selector);
        calculatorFacet.updateFeePercentage(0);
    }

    function testCalculateFee() public {
        calculatorFacet.initCalculator();

        uint256 amount = 1000;
        uint256 expectedFee = (amount * 500) / 10_000;
        uint256 fee = calculatorFacet.calculateFee(amount);
        assertEq(fee, expectedFee);

        vm.expectRevert(CalculatorFacet.CalculatorFacet__InvalidAmount.selector);
        calculatorFacet.calculateFee(1);
    }
}
