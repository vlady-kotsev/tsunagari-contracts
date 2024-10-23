// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title IWrappedToken
/// @notice Interface for a wrapped token with minting and burning capabilities
/// @dev Extends the standard ERC20 interface with additional functions for minting and burning
interface IWrappedToken is IERC20 {
    /// @notice Mints new tokens to a specified address
    /// @param to The address that will receive the minted tokens
    /// @param amount The amount of tokens to mint
    function mint(address to, uint256 amount) external;

    /// @notice Burns tokens from a specified address
    /// @param from The address from which tokens will be burned
    /// @param amount The amount of tokens to burn
    function burnFrom(address from, uint256 amount) external;
}
