// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/// @title ICalculator
/// @notice Interface for fee calculation operations
/// @dev This interface defines the core functions for initializing and managing fee calculations
interface ICalculator {
    /// @notice Initializes the calculator
    /// @dev This function should be called once to set up the initial state of the calculator
    function initCalculator() external;

    /// @notice Calculates the fee for a given amount
    /// @param amount The amount to calculate the fee for
    /// @return The calculated fee
    function calculateFee(uint256 amount) external returns (uint256);

    /// @notice Retrieves the current fee percentage
    /// @return The current fee percentage
    function getFeePercentage() external view returns (uint256);

    /// @notice Updates the fee percentage
    /// @param newFeePercentage The new fee percentage to set
    /// @param message The message that was signed by the authorized parties
    /// @param signatures An array of signatures from the authorized parties
    function updateFeePercentage(uint248 newFeePercentage, bytes memory message, bytes[] memory signatures) external;
}
