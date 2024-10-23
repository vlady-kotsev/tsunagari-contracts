// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ICalculator} from "../interfaces/ICalculator.sol";
import {LibCalculator} from "../libs/LibCalculator.sol";
import {SignatureChecker} from "../utils/SignatureChecker.sol";
import {LibCalculatorErrors} from "./errors/LibCalculatorErrors.sol";

/// @title CalculatorFacet
/// @notice This contract implements fee calculation and management functionality
/// @dev This contract is part of a diamond proxy system and inherits from SignatureChecker
contract CalculatorFacet is ICalculator, SignatureChecker {
    event FeeUpdated(uint256 newFee);
    event FeeCalculated(uint256 fee);

    /// @notice Initializes the calculator facet
    /// @dev Can only be called once
    /// @inheritdoc ICalculator
    function initCalculator() external override {
        LibCalculator.Storage storage lcs = LibCalculator.getCalculatorStorage();
        if (lcs.initialized) {
            revert LibCalculatorErrors.CalculatorFacet__FacetAlreadyInitialized();
        }
        uint248 defaultFeePercentage = 500;

        lcs.initialized = true;
        lcs.feePercentage = defaultFeePercentage;
    }

    /// @notice Retrieves the current fee percentage
    /// @return The current fee percentage in basis points (100 = 1%)
    function getFeePercentage() external pure returns (uint256) {
        LibCalculator.Storage memory lcs = LibCalculator.getCalculatorStorage();
        return lcs.feePercentage;
    }

    /// @notice Updates the fee percentage
    /// @dev Requires signatures from all members
    /// @param newFeePercentage The new fee percentage to set (in basis points, 100 = 1%)
    /// @param message The message that was signed
    /// @param signatures Array of signatures from members
    function updateFeePercentage(uint248 newFeePercentage, bytes memory message, bytes[] memory signatures)
        external
        enforceIsSignedByAllMembers(message, signatures)
    {
        if (newFeePercentage < 1 || newFeePercentage > 10_000) {
            revert LibCalculatorErrors.CalculatorFacet__InvalidFeePercentage();
        }
        LibCalculator.Storage storage lcs = LibCalculator.getCalculatorStorage();
        lcs.feePercentage = newFeePercentage;
        emit FeeUpdated(newFeePercentage);
    }

    /// @notice Calculates the fee for a given amount
    /// @param amount The amount to calculate the fee for
    /// @return The calculated fee
    function calculateFee(uint256 amount) external returns (uint256) {
        LibCalculator.Storage memory lcs = LibCalculator.getCalculatorStorage();
        uint256 feePercentage = lcs.feePercentage;

        if (amount == 0 || type(uint256).max / amount < feePercentage || amount * feePercentage < 10_000) {
            revert LibCalculatorErrors.CalculatorFacet__InvalidAmount();
        }
        uint256 fee = (amount * feePercentage) / 10_000; // percentage in basic points
        emit FeeCalculated(fee);
        return fee;
    }
}
