// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IWrappedToken {
    function mint(address to, uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
}

contract MockWrappedToken is ERC20, IWrappedToken {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external override {
        _mint(to, amount);
    }

    function burnFrom(address account, uint256 amount) external override {
        _burn(account, amount);
    }
}
