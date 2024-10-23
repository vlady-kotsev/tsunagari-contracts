// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/// @title LibCalculatorErrors
/// @notice This library contains custom errors for the CalculatorFacet contract
/// @dev These errors are used to provide more specific information about failures in the CalculatorFacet
library LibCalculatorErrors {
    error CalculatorFacet__FacetAlreadyInitialized();
    error CalculatorFacet__InvalidAmount();
    error CalculatorFacet__InvalidFeePercentage();
}
