// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface ICalculator {
    function initCalculator() external;
    function calculateFee(uint256) external returns (uint256);
    function getFeePercentage() external view returns (uint256);
    function updateFeePercentage(uint248, bytes memory message, bytes[] memory signatures) external;
}
