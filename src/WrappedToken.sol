// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC20, ERC20Burnable} from "@openzeppelincontracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {IWrappedToken} from "./interfaces/IWrappedToken.sol";
import {Ownable} from "@openzeppelincontracts/contracts/access/Ownable.sol";

contract WrappedToken is ERC20, ERC20Burnable, IWrappedToken, Ownable {
    error WrappedToken__InvalidBurnAmount();

    event WrappedTokensBurned(uint256 amount);

    constructor(address owner, string memory tokenName, string memory TokenSymbol)
        ERC20(tokenName, TokenSymbol)
        Ownable(owner)
    {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burnFrom(address from, uint256 amount) public override(ERC20Burnable, IWrappedToken) {
        ERC20Burnable.burnFrom(from, amount);
    }
}
