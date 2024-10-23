// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC20, ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {IWrappedToken} from "./interfaces/IWrappedToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title WrappedToken
/// @notice An ERC20 token that can be minted and burned, representing wrapped assets
/// @dev Inherits from ERC20, ERC20Burnable, IWrappedToken, and Ownable
contract WrappedToken is ERC20, ERC20Burnable, IWrappedToken, Ownable {
    /// @notice Constructs the WrappedToken contract
    /// @param owner The address that will own the contract
    /// @param tokenName The name of the token
    /// @param TokenSymbol The symbol of the token
    constructor(address owner, string memory tokenName, string memory TokenSymbol)
        ERC20(tokenName, TokenSymbol)
        Ownable(owner)
    {}

    /// @notice Mints new tokens
    /// @param to The address to mint tokens to
    /// @param amount The amount of tokens to mint
    /// @dev Only the owner can call this function
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /// @notice Burns tokens from a specific address
    /// @param from The address to burn tokens from
    /// @param amount The amount of tokens to burn
    /// @dev Overrides the burnFrom function from ERC20Burnable and IWrappedToken
    function burnFrom(address from, uint256 amount) public override(ERC20Burnable, IWrappedToken) {
        ERC20Burnable.burnFrom(from, amount);
    }
}
