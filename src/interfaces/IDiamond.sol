// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ICalculator} from "./ICalculator.sol";
import {IDiamondCut} from "./IDiamondCut.sol";
import {IGovernance} from "./IGovernance.sol";
import {ITokenManager} from "./ITokenManager.sol";
import {IDiamondLoupe} from "./IDiamondLoupe.sol";

/// @title IDiamond
/// @notice Composite interface for the Diamond contract
/// @dev This interface combines multiple interfaces to define the complete functionality of the Diamond contract
interface IDiamond is ICalculator, IDiamondCut, IGovernance, ITokenManager, IDiamondLoupe {
// The IDiamond interface inherits all functions from the imported interfaces
}
