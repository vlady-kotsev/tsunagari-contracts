// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ICalculator} from "../interfaces/ICalculator.sol";
import {LibCalculator} from "../libs/LibCalculator.sol";

contract CalculatorFacet is ICalculator {
    error CalculatorFacet__FacetAlreadyInitialized();
    error CalculatorFacet__InvalidAmount();
    error CalculatorFacet__InvalidFeePercentage();

    event FeeUpdated(uint256 newFee);

    function initCalculator() external override {
        LibCalculator.Storage storage lcs = LibCalculator.getCalculatorStorage();
        if (lcs.initialized) {
            revert CalculatorFacet__FacetAlreadyInitialized();
        }
        uint256 defaultFeePercentage = 5;

        lcs.initialized = true;
        lcs.feePercentage = defaultFeePercentage;
    }

    function getFeePercentage() external pure returns (uint256) {
        LibCalculator.Storage memory lcs = LibCalculator.getCalculatorStorage();
        return lcs.feePercentage;
    }

    function updateFeePercentage(uint256 newFeePercentage) external override {
        if (newFeePercentage < 1 && newFeePercentage > 100) {
            revert CalculatorFacet__InvalidFeePercentage();
        }
        LibCalculator.Storage storage lcs = LibCalculator.getCalculatorStorage();
        lcs.feePercentage = newFeePercentage;
        emit FeeUpdated(newFeePercentage);
    }

    function calculateFee(uint256 amount) external view returns (uint256) {
        if (amount < 100) {
            // minimal amount
            revert CalculatorFacet__InvalidAmount();
        }
        LibCalculator.Storage storage lcs = LibCalculator.getCalculatorStorage();
        uint256 fee = (amount * lcs.feePercentage) / 100;
        return fee;
    }

    function newFunc() external pure returns (uint256) {
        return 77;
    }
}
