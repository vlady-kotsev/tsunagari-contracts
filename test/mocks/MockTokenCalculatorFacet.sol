// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract MockCalculatorFacet {
    function getFeePercentage() external pure returns (uint256) {
        return 9999;
    }

    function callToRevert() external pure {
        revert("Revert!");
    }
}
