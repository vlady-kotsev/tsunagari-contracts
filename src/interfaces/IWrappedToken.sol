// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelincontracts/contracts/token/ERC20/IERC20.sol";

interface IWrappedToken is IERC20 {
    function mint(address to, uint256 amount) external;
    function burnFrom(address from, uint256 amount) external;
}
