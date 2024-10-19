// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test} from "forge-std/Test.sol";
import {Diamond} from "../../src/Diamond.sol";
import {IDiamond} from "../../src/interfaces/IDiamond.sol";
import {DeployDiamond} from "../../script/Diamond.deploy.s.sol";
import {SignatureGenerator} from "../../src/utils/SignatureGenerator.sol";
import {MockWrappedToken} from "../mocks/MockWrappedToken.sol";
import {MockERC20} from "../mocks/MockERC20.sol";
import {TokenManagerFacet} from "../../src/facets/TokenManagerFacet.sol";

contract TokenManagerFacetFuzzTest is Test, SignatureGenerator {
    IDiamond diamond;
    address user;
    MockERC20 mockERC20;
    MockWrappedToken mockWrapped;

    function setUp() public {
        user = address(123);
        DeployDiamond dd = new DeployDiamond();
        Diamond d = dd.run(true);
        diamond = IDiamond(address(d));

        uint256 threshold = diamond.getThreshold();
        initSignatureGenerator(threshold);
        
        //init tokens
        mockERC20 = new MockERC20("Mock Token", "MTK", 18);
        mockWrapped = new MockWrappedToken("Mock Wrapped Token", "MWTK");
        
        // add tokens
        messageWithNonce = getUniqueSignature();
        diamond.addNewSupportedToken(address(mockERC20), messageWithNonce, signatures);

        messageWithNonce = getUniqueSignature();
        diamond.addNewSupportedToken(address(mockWrapped), messageWithNonce, signatures);
    }

    function testFuzzSetTokenManagerMinBridgeableAmount(uint248 minBridgeableAmount) public {
        messageWithNonce = getUniqueSignature();
        vm.assume(minBridgeableAmount != 0);
        diamond.setMinimumBridgeableAmount(minBridgeableAmount, messageWithNonce, signatures);
    }

    function testFuzzMintWrappedTokens(uint256 mintAmount) public {
        vm.assume(mintAmount != 0);
        messageWithNonce = getUniqueSignature();
        diamond.mintWrappedTokens(mintAmount, user, address(mockWrapped), bytes(messageWithNonce), signatures);
        assertEq(mockWrapped.balanceOf(user), mintAmount);
    }

    function testFuzzBurnWrappedTokens(uint256 burnAmount) public {
        uint256 minAmount = diamond.getMinimumBridgeableAmount();
        vm.assume(burnAmount > minAmount);
        messageWithNonce = getUniqueSignature();
        diamond.mintWrappedTokens(burnAmount, user, address(mockWrapped), messageWithNonce, signatures);
        assertEq(mockWrapped.balanceOf(user), burnAmount);

        vm.prank(user);
        diamond.burnWrappedToken(burnAmount, address(mockWrapped));

        assertEq(mockWrapped.balanceOf(address(user)), 0);
    }

    function testFuzzLockTokens(uint256 lockAmount) public {
        uint256 minAmount = diamond.getMinimumBridgeableAmount();
        uint256 feePercentage = diamond.getFeePercentage();

        vm.assume(
            lockAmount > minAmount && type(uint256).max / lockAmount >= feePercentage
                && lockAmount * feePercentage >= 10_000
        );
        mockERC20.mint(user, lockAmount);

        assertEq(mockERC20.balanceOf(user), lockAmount);

        vm.prank(user);
        mockERC20.approve(address(diamond), lockAmount);

        assertEq(mockERC20.allowance(user, address(diamond)), lockAmount);

        uint256 fee = diamond.calculateFee(lockAmount);
        uint256 amountWithoutFee = lockAmount - fee;

        vm.expectEmit(true, true, false, true, address(diamond));
        emit TokenManagerFacet.TokensLocked(user, address(mockERC20), amountWithoutFee);

        vm.prank(user);
        diamond.lockTokens(lockAmount, address(mockERC20));

        assertEq(mockERC20.balanceOf(address(diamond)), lockAmount);

        assertEq(mockERC20.balanceOf(user), 0);
    }
}
