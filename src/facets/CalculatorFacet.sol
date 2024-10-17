// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ICalculator} from "../interfaces/ICalculator.sol";
import {LibCalculator} from "../libs/LibCalculator.sol";
import {SignatureChecker} from "../utils/SignatureChecker.sol";

contract CalculatorFacet is ICalculator, SignatureChecker {
    error CalculatorFacet__FacetAlreadyInitialized();
    error CalculatorFacet__InvalidAmount();
    error CalculatorFacet__InvalidFeePercentage();

    event FeeUpdated(uint256 newFee);

    function initCalculator() external override {
        LibCalculator.Storage storage lcs = LibCalculator.getCalculatorStorage();
        if (lcs.initialized) {
            revert CalculatorFacet__FacetAlreadyInitialized();
        }
        uint256 defaultFeePercentage = 500;

        lcs.initialized = true;
        lcs.feePercentage = defaultFeePercentage;
    }

    function getFeePercentage() external pure returns (uint256) {
        LibCalculator.Storage memory lcs = LibCalculator.getCalculatorStorage();
        return lcs.feePercentage;
    }

    function updateFeePercentage(uint256 newFeePercentage, bytes memory message, bytes[] memory signatures)
        external
        override
        enforceIsSignedByAllMembers(message, signatures)
    {
        if (newFeePercentage < 1 || newFeePercentage > 10_000) {
            revert CalculatorFacet__InvalidFeePercentage();
        }
        LibCalculator.Storage storage lcs = LibCalculator.getCalculatorStorage();
        lcs.feePercentage = newFeePercentage;
        emit FeeUpdated(newFeePercentage);
    }

    function calculateFee(uint256 amount) external pure returns (uint256) {
        LibCalculator.Storage memory lcs = LibCalculator.getCalculatorStorage();
        uint256 feePercentage = lcs.feePercentage;

        if (amount == 0 || type(uint256).max / amount < feePercentage || amount * feePercentage < 10_000) {
            revert CalculatorFacet__InvalidAmount();
        }
        uint256 fee = (amount * feePercentage) / 10_000; // percentage in basic points
        return fee;
    }
}
