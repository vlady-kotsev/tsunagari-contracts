// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {CalculatorFacet} from "../src/facets/CalculatorFacet.sol";
import {DeployCalculatorFacet} from "../script/CalculatorFacet.deploy.s.sol";
import {DeployDiamond} from "../script/Diamond.deploy.s.sol";
import {IDiamond} from "../src/interfaces/IDiamond.sol";
import {Diamond} from "../src/Diamond.sol";
import {IDiamondCut} from "../src/interfaces/IDiamondCut.sol";
import {LibDiamond} from "../src/libs/LibDiamond.sol";
import {MockCalculatorFacet} from "./mocks/MockTokenCalculatorFacet.sol";
import {DeployMockCalculatorFacet} from "../script/MockCalculatorFacet.deploy.s.sol";
import {DiamondCutFacet} from "../src/facets/DiamondCutFacet.sol";
import {SignatureGenerator} from "../src/utils/SignatureGenerator.sol";

contract DiamondCutFacetTest is Test, SignatureGenerator {
    CalculatorFacet calculatorFacet;
    IDiamond diamond;

    function setUp() public {
        DeployCalculatorFacet dcf = new DeployCalculatorFacet();
        calculatorFacet = dcf.run();

        DeployDiamond dd = new DeployDiamond();
        Diamond d = dd.run(false);

        diamond = IDiamond(address(d));
        uint256 threshold = diamond.getThreshold();
        initSignatureGenerator(threshold);
    }

    function testDiamondCutAdd() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory calculatorFacetSelectors = new bytes4[](4);
        calculatorFacetSelectors[0] = CalculatorFacet.getFeePercentage.selector;
        calculatorFacetSelectors[1] = CalculatorFacet.updateFeePercentage.selector;
        calculatorFacetSelectors[2] = CalculatorFacet.calculateFee.selector;
        calculatorFacetSelectors[3] = CalculatorFacet.initCalculator.selector;
        cuts[0] =
            IDiamondCut.FacetCut(address(calculatorFacet), IDiamondCut.FacetCutAction.Add, calculatorFacetSelectors);

        vm.expectRevert(
            abi.encodeWithSelector(Diamond.Diamond__FacetDoesntExist.selector, CalculatorFacet.initCalculator.selector)
        );
        diamond.initCalculator();

        messageWithNonce = getUniqueSignature();
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce, signatures);

        diamond.initCalculator();
        uint256 feePercentage = diamond.getFeePercentage();
        assertEq(feePercentage, 500);
    }

    function testDiamondCutAddInvalidFunctionSelector() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory calculatorFacetSelectors = new bytes4[](1);
        calculatorFacetSelectors[0] = bytes4(0); //invalid function selector
        cuts[0] =
            IDiamondCut.FacetCut(address(calculatorFacet), IDiamondCut.FacetCutAction.Add, calculatorFacetSelectors);

        messageWithNonce = getUniqueSignature();
        vm.expectRevert(LibDiamond.LibDiamond__InvalidFunctionSelector.selector);
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce, signatures);
    }

    function testDiamondCutAddInvalidFacetAddress() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory calculatorFacetSelectors = new bytes4[](1);
        address invalidAddress = address(0);
        calculatorFacetSelectors[0] = CalculatorFacet.getFeePercentage.selector;
        cuts[0] = IDiamondCut.FacetCut(invalidAddress, IDiamondCut.FacetCutAction.Add, calculatorFacetSelectors);

        messageWithNonce = getUniqueSignature();
        vm.expectRevert(LibDiamond.LibDiamond__InvalidFunctionAddress.selector);
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce,signatures);
    }

    function testDiamondCutAddFunctionAlreadyAdded() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory calculatorFacetSelectors = new bytes4[](1);

        calculatorFacetSelectors[0] = CalculatorFacet.getFeePercentage.selector;
        cuts[0] =
            IDiamondCut.FacetCut(address(calculatorFacet), IDiamondCut.FacetCutAction.Add, calculatorFacetSelectors);

        messageWithNonce = getUniqueSignature();
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce,signatures);

        messageWithNonce = getUniqueSignature();
        vm.expectRevert(LibDiamond.LibDiamond__FunctionAlreadyAdded.selector);
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce, signatures);
    }

    function testDiamondCutRemove() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory calculatorFacetSelectors = new bytes4[](4);
        calculatorFacetSelectors[0] = CalculatorFacet.getFeePercentage.selector;
        calculatorFacetSelectors[1] = CalculatorFacet.updateFeePercentage.selector;
        calculatorFacetSelectors[2] = CalculatorFacet.calculateFee.selector;
        calculatorFacetSelectors[3] = CalculatorFacet.initCalculator.selector;
        cuts[0] =
            IDiamondCut.FacetCut(address(calculatorFacet), IDiamondCut.FacetCutAction.Add, calculatorFacetSelectors);
        
        messageWithNonce = getUniqueSignature();
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce, signatures);

        diamond.initCalculator();
        uint256 feePercentage = diamond.getFeePercentage();
        assertEq(feePercentage, 500);

        cuts[0] =
            IDiamondCut.FacetCut(address(calculatorFacet), IDiamondCut.FacetCutAction.Remove, calculatorFacetSelectors);
        messageWithNonce = getUniqueSignature();
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce,signatures);

        vm.expectRevert(
            abi.encodeWithSelector(Diamond.Diamond__FacetDoesntExist.selector, CalculatorFacet.initCalculator.selector)
        );
        diamond.initCalculator();
    }

    function testDiamondCutRemoveInvalidFunctionSelector() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory calculatorFacetSelectors = new bytes4[](1);
        calculatorFacetSelectors[0] = bytes4(0); //invalid function selector
        cuts[0] =
            IDiamondCut.FacetCut(address(calculatorFacet), IDiamondCut.FacetCutAction.Remove, calculatorFacetSelectors);

        messageWithNonce = getUniqueSignature();
        vm.expectRevert(LibDiamond.LibDiamond__InvalidFunctionSelector.selector);
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce, signatures);
    }

    function testDiamondCutRemoveInvalidFacetAddress() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory calculatorFacetSelectors = new bytes4[](1);
        address invalidAddress = address(0);
        calculatorFacetSelectors[0] = CalculatorFacet.getFeePercentage.selector;
        cuts[0] = IDiamondCut.FacetCut(invalidAddress, IDiamondCut.FacetCutAction.Remove, calculatorFacetSelectors);

        messageWithNonce = getUniqueSignature();
        vm.expectRevert(LibDiamond.LibDiamond__FunctionDoesntExist.selector);
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce,signatures);
    }

    function testDiamondCutRemoveWholeFacet() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory calculatorFacetSelectors = new bytes4[](1);
        calculatorFacetSelectors[0] = CalculatorFacet.initCalculator.selector;
        cuts[0] =
            IDiamondCut.FacetCut(address(calculatorFacet), IDiamondCut.FacetCutAction.Add, calculatorFacetSelectors);
        
        messageWithNonce = getUniqueSignature();
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce,signatures);

        diamond.initCalculator();

        cuts[0] =
            IDiamondCut.FacetCut(address(calculatorFacet), IDiamondCut.FacetCutAction.Remove, calculatorFacetSelectors);

        messageWithNonce = getUniqueSignature();
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce, signatures);

        vm.expectRevert(
            abi.encodeWithSelector(Diamond.Diamond__FacetDoesntExist.selector, CalculatorFacet.initCalculator.selector)
        );
        diamond.initCalculator();
    }

    function testDiamondCutRemoveWholeFacetFromNotLastFacet() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory diamondCutFacetSelectors = new bytes4[](1);
        diamondCutFacetSelectors[0] = DiamondCutFacet.diamondCut.selector;

        cuts[0] =
            IDiamondCut.FacetCut(address(calculatorFacet), IDiamondCut.FacetCutAction.Remove, diamondCutFacetSelectors);
        
        messageWithNonce = getUniqueSignature();
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce, signatures);

        messageWithNonce = getUniqueSignature();
        vm.expectRevert(
            abi.encodeWithSelector(Diamond.Diamond__FacetDoesntExist.selector, DiamondCutFacet.diamondCut.selector)
        );
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce,signatures);
    }

    function testDiamondCutRemoveLastFunctionInFacet() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory calculatorFacetSelectors = new bytes4[](4);
        calculatorFacetSelectors[0] = CalculatorFacet.getFeePercentage.selector;
        calculatorFacetSelectors[1] = CalculatorFacet.updateFeePercentage.selector;
        calculatorFacetSelectors[2] = CalculatorFacet.calculateFee.selector;
        calculatorFacetSelectors[3] = CalculatorFacet.initCalculator.selector;
        cuts[0] =
            IDiamondCut.FacetCut(address(calculatorFacet), IDiamondCut.FacetCutAction.Add, calculatorFacetSelectors);

        messageWithNonce = getUniqueSignature();
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce,signatures);

        diamond.initCalculator();
        uint256 feePercentage = diamond.getFeePercentage();
        assertEq(feePercentage, 500);

        bytes4[] memory calculatorFacetSelectorsOnlyLast = new bytes4[](1);
        calculatorFacetSelectorsOnlyLast[0] = CalculatorFacet.initCalculator.selector;

        cuts[0] = IDiamondCut.FacetCut(
            address(calculatorFacet), IDiamondCut.FacetCutAction.Remove, calculatorFacetSelectorsOnlyLast
        );

        messageWithNonce = getUniqueSignature(); 
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce,signatures);

        vm.expectRevert(
            abi.encodeWithSelector(Diamond.Diamond__FacetDoesntExist.selector, CalculatorFacet.initCalculator.selector)
        );
        diamond.initCalculator();
    }

    function testDiamondCutReplace() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory calculatorFacetSelectors = new bytes4[](4);
        calculatorFacetSelectors[0] = CalculatorFacet.getFeePercentage.selector;
        calculatorFacetSelectors[1] = CalculatorFacet.updateFeePercentage.selector;
        calculatorFacetSelectors[2] = CalculatorFacet.calculateFee.selector;
        calculatorFacetSelectors[3] = CalculatorFacet.initCalculator.selector;
        cuts[0] =
            IDiamondCut.FacetCut(address(calculatorFacet), IDiamondCut.FacetCutAction.Add, calculatorFacetSelectors);

        vm.expectRevert(
            abi.encodeWithSelector(Diamond.Diamond__FacetDoesntExist.selector, CalculatorFacet.initCalculator.selector)
        );
        diamond.initCalculator();

        messageWithNonce = getUniqueSignature();
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce,signatures);

        diamond.initCalculator();
        uint256 feePercentage = diamond.getFeePercentage();
        assertEq(feePercentage, 500);

        DeployMockCalculatorFacet dmcf = new DeployMockCalculatorFacet();
        MockCalculatorFacet mockCalculatorFacet = dmcf.run();

        bytes4[] memory mockCalculatorFacetSelectors = new bytes4[](1);
        mockCalculatorFacetSelectors[0] = MockCalculatorFacet.getFeePercentage.selector;

        cuts[0] = IDiamondCut.FacetCut(
            address(mockCalculatorFacet), IDiamondCut.FacetCutAction.Replace, mockCalculatorFacetSelectors
        );

        messageWithNonce = getUniqueSignature();
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce,signatures);

        uint256 expectedMockCalculatorPercentage = 9999;
        uint256 actualMockCalculatorPercentage = diamond.getFeePercentage();
        assertEq(expectedMockCalculatorPercentage, actualMockCalculatorPercentage);
    }

    function testDiamondCutReplaceInvalidFunctionSelector() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory calculatorFacetSelectors = new bytes4[](1);
        calculatorFacetSelectors[0] = bytes4(0); //invalid function selector
        cuts[0] =
            IDiamondCut.FacetCut(address(calculatorFacet), IDiamondCut.FacetCutAction.Replace, calculatorFacetSelectors);

        messageWithNonce = getUniqueSignature();
        vm.expectRevert(LibDiamond.LibDiamond__InvalidFunctionSelector.selector);
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce, signatures);
    }

    function testDiamondCutReplaceInvalidFacetAddress() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory calculatorFacetSelectors = new bytes4[](1);
        address invalidAddress = address(0);
        calculatorFacetSelectors[0] = CalculatorFacet.getFeePercentage.selector;
        cuts[0] = IDiamondCut.FacetCut(invalidAddress, IDiamondCut.FacetCutAction.Replace, calculatorFacetSelectors);

        messageWithNonce = getUniqueSignature();
        vm.expectRevert(LibDiamond.LibDiamond__InvalidFunctionAddress.selector);
        diamond.diamondCut(cuts, address(0), new bytes(0),messageWithNonce,signatures);
    }

    function testInitializeDiamondCutAddressZeroWithCalldata() public {
        bytes memory calldataNonEmpty = abi.encodeWithSignature("someFunction()");

        vm.expectRevert(LibDiamond.LibDiamond__InvalidCalldataLengthForAddressZero.selector);
        LibDiamond.initializeDiamondCut(address(0), calldataNonEmpty);
    }

    function testInitializeDiamondCutNonZeroAddressWithEmptyCalldata() public {
        bytes memory calldataEmpty = new bytes(0);
        address nonZeroAddress = address(1);

        vm.expectRevert(LibDiamond.LibDiamond__InvalidCalldataLengthForNotAddressZero.selector);
        LibDiamond.initializeDiamondCut(nonZeroAddress, calldataEmpty);
    }

    function testInitializeDiamondCutValidInitContractAndCalldata() public {
        MockCalculatorFacet mockContract = new MockCalculatorFacet();

        bytes memory validCalldata = abi.encodeWithSignature("getFeePercentage()");

        LibDiamond.initializeDiamondCut(address(mockContract), validCalldata);
    }

    function testInitializeDiamondCutNonContractCode() public {
        bytes memory callData = abi.encodeWithSignature("mockFunction()");
        address nonContractAddress = address(0x123);

        vm.expectRevert(LibDiamond.LibDiamond__InvalidExternalContractSize.selector);
        LibDiamond.initializeDiamondCut(nonContractAddress, callData);
    }

    function testInitializeDiamondCutWithDelegateCallFailureNoError() public {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory calculatorFacetSelectors = new bytes4[](1);
        calculatorFacetSelectors[0] = CalculatorFacet.getFeePercentage.selector;

        cuts[0] =
            IDiamondCut.FacetCut(address(calculatorFacet), IDiamondCut.FacetCutAction.Add, calculatorFacetSelectors);

        vm.expectRevert(
            abi.encodeWithSelector(Diamond.Diamond__FacetDoesntExist.selector, CalculatorFacet.initCalculator.selector)
        );
        diamond.initCalculator();

        messageWithNonce = getUniqueSignature();
        vm.expectRevert(LibDiamond.LibDiamond__InitFunctionReverted.selector);
        diamond.diamondCut(cuts, address(calculatorFacet), abi.encodeWithSignature("newFunc()"),messageWithNonce,signatures);
    }

    function testInitializeDiamondCutWithDelegateCallFailureWithError() public {
        MockCalculatorFacet mock = new MockCalculatorFacet();

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory calculatorFacetSelectors = new bytes4[](1);
        calculatorFacetSelectors[0] = MockCalculatorFacet.callToRevert.selector;

        cuts[0] = IDiamondCut.FacetCut(address(mock), IDiamondCut.FacetCutAction.Add, calculatorFacetSelectors);
        string memory expectedRevertMessage = "Revert!";

        messageWithNonce = getUniqueSignature();
        vm.expectRevert(abi.encodeWithSignature("Error(string)", expectedRevertMessage));
        diamond.diamondCut(cuts, address(mock), abi.encodeWithSignature("callToRevert()"),messageWithNonce,signatures);
    }
}
