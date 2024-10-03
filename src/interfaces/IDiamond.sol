// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ICalculator} from "./ICalculator.sol";
import {IDiamondCut} from "./IDiamondCut.sol";
import {IGovernance} from "./IGovernance.sol";
import {ITokenManager} from "./ITokenManager.sol";

interface IDiamond is ICalculator, IDiamondCut, IGovernance, ITokenManager {}
