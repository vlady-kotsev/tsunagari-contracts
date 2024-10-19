// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {CalculatorFacet} from "../../src/facets/CalculatorFacet.sol";

contract CalculatorFacetFuzzTest is Test {
    CalculatorFacet calculatorFacet;

    function setUp() public {
        calculatorFacet = new CalculatorFacet();
    }

    function testFuzzCalculateFee(uint256 amount) public {
        calculatorFacet.initCalculator();
        uint256 feePercentage = calculatorFacet.getFeePercentage();

        vm.assume(amount != 0 && type(uint256).max / amount >= feePercentage && amount * feePercentage >= 10_000);
        uint256 expectedFee = (amount * feePercentage) / 10_000;
        uint256 fee = calculatorFacet.calculateFee(amount);
        assertEq(fee, expectedFee);
    }
}
