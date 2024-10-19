// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {CalculatorFacet} from "../src/facets/CalculatorFacet.sol";
import {DeployCalculatorFacet} from "../script/CalculatorFacet.deploy.s.sol";
import {SignatureGenerator} from "../src/utils/SignatureGenerator.sol";
import {DeployDiamond} from "../script/Diamond.deploy.s.sol";
import {IDiamond} from "../src/interfaces/IDiamond.sol";
import {Diamond} from "../src/Diamond.sol";
import {CalculatorErrors} from "../src/facets/errors/CalculatorErrors.sol";

contract CalculatorFacetTest is Test, SignatureGenerator {
    CalculatorFacet calculatorFacet;
    IDiamond diamond;

    function setUp() public {
        DeployCalculatorFacet dcf = new DeployCalculatorFacet();
        calculatorFacet = dcf.run();
        DeployDiamond dd = new DeployDiamond();
        Diamond d = dd.run(true);
        diamond = IDiamond(address(d));
        uint256 threshold = diamond.getThreshold();
        initSignatureGenerator(threshold);
    }

    function testInitCalculator() public {
        calculatorFacet.initCalculator();

        assertEq(calculatorFacet.getFeePercentage(), 500);
        vm.expectRevert(CalculatorErrors.CalculatorFacet__FacetAlreadyInitialized.selector);
        calculatorFacet.initCalculator();
    }

    function testGetFeePercentage() public view {
        uint256 feePercentage = diamond.getFeePercentage();
        assertEq(feePercentage, 500);
    }

    function testUpdateFeePercentage() public {
        messageWithNonce = getUniqueSignature();
        diamond.updateFeePercentage(1000, messageWithNonce, signatures);

        uint256 updatedFee = diamond.getFeePercentage();
        assertEq(updatedFee, 1000);

        messageWithNonce = getUniqueSignature();
        vm.expectRevert(CalculatorErrors.CalculatorFacet__InvalidFeePercentage.selector);
        diamond.updateFeePercentage(10001, messageWithNonce, signatures);

        messageWithNonce = getUniqueSignature();
        vm.expectRevert(CalculatorErrors.CalculatorFacet__InvalidFeePercentage.selector);
        diamond.updateFeePercentage(10001, messageWithNonce, signatures);
    }

    function testCalculateFee() public {
        calculatorFacet.initCalculator();

        uint256 amount = 1000;
        uint256 expectedFee = (amount * 500) / 10_000;
        uint256 fee = calculatorFacet.calculateFee(amount);
        assertEq(fee, expectedFee);

        vm.expectRevert(CalculatorErrors.CalculatorFacet__InvalidAmount.selector);
        calculatorFacet.calculateFee(1);
    }
}
