// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test} from "forge-std/Test.sol";
import {WrappedToken} from "../src/WrappedToken.sol";

contract WrappedTokenTest is Test {
    WrappedToken private wrappedToken;
    address private owner;
    address private user;

    function setUp() public {
        owner = address(this);
        user = address(0x123);
        wrappedToken = new WrappedToken(owner, "Wrapped Token", "WT");
    }

    function testMint() public {
        uint256 mintAmount = 1000;

        wrappedToken.mint(user, mintAmount);

        uint256 userBalance = wrappedToken.balanceOf(user);
        assertEq(userBalance, mintAmount, "User should have received minted tokens");
    }

    function testBurnFrom() public {
        uint256 mintAmount = 1000;
        uint256 burnAmount = 500;
        address burner = address(0x13);

        wrappedToken.mint(user, mintAmount);

        vm.prank(user);
        wrappedToken.approve(burner, burnAmount);

        vm.prank(burner);
        wrappedToken.burnFrom(user, burnAmount);

        uint256 userBalance = wrappedToken.balanceOf(user);
        assertEq(userBalance, mintAmount - burnAmount, "User balance should reflect burned tokens");
    }
}
