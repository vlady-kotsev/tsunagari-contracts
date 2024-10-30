// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test} from "forge-std/Test.sol";
import {TokenManagerFacet} from "../src/facets/TokenManagerFacet.sol";
import {MockERC20} from "./mocks/MockERC20.sol";
import {MockWrappedToken} from "./mocks/MockWrappedToken.sol";
import {DeployDiamond} from "../script/Diamond.deploy.s.sol";
import {IDiamond} from "../src/interfaces/IDiamond.sol";
import {Diamond} from "../src/Diamond.sol";
import {DeployTokenManagerFacet} from "../script/TokenManagerFacet.deploy.s.sol";
import {SignatureGenerator} from "../src/utils/SignatureGenerator.sol";
import {LibTokenManagerErrors} from "../src/facets/errors/LibTokenManagerErrors.sol";
import {ITokenManager} from "../src/interfaces/ITokenManager.sol";

contract TokenManagerFacetTest is Test, SignatureGenerator {
    MockERC20 mockToken;
    MockWrappedToken mockWrappedToken;
    IDiamond diamond;
    address user;
    uint256 destinationChainId;

    function setUp() public {
        DeployDiamond dd = new DeployDiamond();
        Diamond d = dd.run(true);
        diamond = IDiamond(address(d));
        uint256 threshold = diamond.getThreshold();
        user = address(123);
        initSignatureGenerator(threshold);

        mockToken = new MockERC20("Mock Token", "MTK", 18);
        mockWrappedToken = new MockWrappedToken("Mock Wrapped Token", "MWTK");

        messageWithNonce = getUniqueSignature(1);
        diamond.addNewSupportedToken(address(mockToken), messageWithNonce, signatures);

        messageWithNonce = getUniqueSignature(1);
        diamond.addNewSupportedToken(address(mockWrappedToken), messageWithNonce, signatures);
        destinationChainId = 123;
    }

    function testInitTokenManagerAlreadyInitialized() public {
        vm.expectRevert(LibTokenManagerErrors.TokenManager__FacetAlreadyInitialized.selector);
        diamond.initTokenManager(10, address(10));
    }

    function testInitTokenManagerInvalidMinBridgeableAmount() public {
        DeployTokenManagerFacet dtmf = new DeployTokenManagerFacet();
        TokenManagerFacet tokenManagerFacet = dtmf.run();

        uint248 invalidMinBridgeableAmount = 0;
        vm.expectRevert(LibTokenManagerErrors.TokenManager__InvalidMinBridgeableAmount.selector);
        tokenManagerFacet.initTokenManager(invalidMinBridgeableAmount, address(10));
    }

    function testInitTokenManagerInvalidTreasuryAddress() public {
        DeployTokenManagerFacet dtmf = new DeployTokenManagerFacet();
        TokenManagerFacet tokenManagerFacet = dtmf.run();

        address invalidTreasuryAddress = address(0);
        vm.expectRevert(LibTokenManagerErrors.TokenManager__InvalidTreasuryAddress.selector);
        tokenManagerFacet.initTokenManager(100, invalidTreasuryAddress);
    }

    function testMintWrappedTokens() public {
        uint256 amount = 50;

        messageWithNonce = getUniqueSignature(1);
        diamond.mintWrappedTokens(amount, user, address(mockWrappedToken), messageWithNonce, signatures);
        assertEq(mockWrappedToken.balanceOf(user), amount);
    }

    function testMintWrappedTokensInvalidMintReceiverAddress() public {
        uint256 amount = 50;
        address invalidReceiver = address(0);

        messageWithNonce = getUniqueSignature(1);
        vm.expectRevert(LibTokenManagerErrors.TokenManager__InvalidMintReceiverAddress.selector);
        diamond.mintWrappedTokens(amount, invalidReceiver, address(mockWrappedToken), messageWithNonce, signatures);
    }

    function testMintWrappedTokensInvalidMintAmount() public {
        uint256 invalidAmount = 0;

        messageWithNonce = getUniqueSignature(1);
        vm.expectRevert(LibTokenManagerErrors.TokenManager__InvalidMintAmount.selector);
        diamond.mintWrappedTokens(invalidAmount, user, address(mockWrappedToken), messageWithNonce, signatures);
    }

    function testMintWrappedTokensNotSupportedWrappedToken() public {
        uint256 amount = 50;
        address invalidWrappedTokenAddress = address(0);

        messageWithNonce = getUniqueSignature(1);

        vm.expectRevert(
            abi.encodeWithSelector(
                LibTokenManagerErrors.TokenManager__TokenNotSupported.selector, invalidWrappedTokenAddress
            )
        );
        diamond.mintWrappedTokens(amount, user, invalidWrappedTokenAddress, messageWithNonce, signatures);
    }

    function testBurnWrappedTokens() public {
        uint256 amount = diamond.getMinimumBridgeableAmount();

        messageWithNonce = getUniqueSignature(1);
        diamond.mintWrappedTokens(amount, user, address(mockWrappedToken), messageWithNonce, signatures);
        assertEq(mockWrappedToken.balanceOf(user), amount);

        vm.prank(user);
        diamond.burnWrappedToken(amount, address(mockWrappedToken), destinationChainId);

        assertEq(mockWrappedToken.balanceOf(address(user)), 0);
    }

    function testBurnWrappedTokensInvalidBurnAmount() public {
        uint256 invalidAmount = 0;

        vm.expectRevert(
            abi.encodeWithSelector(LibTokenManagerErrors.TokenManager__InvalidTransferAmount.selector, invalidAmount)
        );
        diamond.burnWrappedToken(invalidAmount, address(mockWrappedToken), destinationChainId);
    }

    function testBurnWrappedTokensNotSupportedToken() public {
        uint256 amount = 50;
        address invalidTokenAddress = address(0);

        vm.expectRevert(
            abi.encodeWithSelector(LibTokenManagerErrors.TokenManager__TokenNotSupported.selector, invalidTokenAddress)
        );
        diamond.burnWrappedToken(amount, invalidTokenAddress, destinationChainId);
    }

    function testLockTokens() public {
        uint256 lockAmount = diamond.getMinimumBridgeableAmount();
        mockToken.mint(user, lockAmount);

        assertEq(mockToken.balanceOf(user), lockAmount);

        vm.prank(user);
        mockToken.approve(address(diamond), lockAmount);

        assertEq(mockToken.allowance(user, address(diamond)), lockAmount);

        uint256 fee = diamond.calculateFee(lockAmount);
        uint256 amountWithoutFee = lockAmount - fee;

        vm.expectEmit(true, true, false, true, address(diamond));
        emit ITokenManager.TokensLocked(user, address(mockToken), amountWithoutFee, destinationChainId);

        vm.prank(user);
        diamond.lockTokens(lockAmount, address(mockToken), destinationChainId);

        assertEq(mockToken.balanceOf(address(diamond)), lockAmount);

        assertEq(mockToken.balanceOf(user), 0);
    }

    function testLockTokensInvalidLockAmount() public {
        uint256 invalidAmount = 100;

        vm.expectRevert(
            abi.encodeWithSelector(LibTokenManagerErrors.TokenManager__InvalidTransferAmount.selector, invalidAmount)
        );
        diamond.lockTokens(invalidAmount, address(mockWrappedToken), destinationChainId);
    }

    function testLockTokensNotSupportedToken() public {
        uint256 amount = 50;
        address invalidTokenAddress = address(0);

        vm.expectRevert(
            abi.encodeWithSelector(LibTokenManagerErrors.TokenManager__TokenNotSupported.selector, invalidTokenAddress)
        );
        diamond.lockTokens(amount, invalidTokenAddress, destinationChainId);
    }

    function testUnlockTokens() public {
        uint256 amount = diamond.getMinimumBridgeableAmount();

        mockToken.mint(address(user), amount);
        assertEq(mockToken.balanceOf(user), amount);

        vm.prank(user);
        mockToken.approve(address(diamond), amount);
        vm.prank(user);
        diamond.lockTokens(amount, address(mockToken), destinationChainId);

        assertEq(mockToken.balanceOf(user), 0);

        messageWithNonce = getUniqueSignature(1);
        diamond.unlockTokens(amount, user, address(mockToken), messageWithNonce, signatures);

        uint256 fee = diamond.calculateFee(amount);
        uint256 amountWithoutFee = amount - fee;

        assertEq(mockToken.balanceOf(user), amountWithoutFee);
    }

    function testUnlockTokensInvalidAmount() public {
        uint256 invalidAmount = 0;

        messageWithNonce = getUniqueSignature(1);
        vm.expectRevert(LibTokenManagerErrors.TokenManager__InvalidUnlockAmount.selector);
        diamond.unlockTokens(invalidAmount, user, address(mockWrappedToken), messageWithNonce, signatures);
    }

    function testUnlockTokensInvalidReceiverAddress() public {
        uint256 amount = 50;
        address invalidReceiverAddress = address(0);

        messageWithNonce = getUniqueSignature(1);
        vm.expectRevert(LibTokenManagerErrors.TokenManager__InvalidUnlockReceiverAddress.selector);
        diamond.unlockTokens(amount, invalidReceiverAddress, address(mockWrappedToken), messageWithNonce, signatures);
    }

    function testUnlockTokenNotSupportedToken() public {
        uint256 amount = 50;
        address invalidTokenAddress = address(0);

        messageWithNonce = getUniqueSignature(1);
        vm.expectRevert(
            abi.encodeWithSelector(LibTokenManagerErrors.TokenManager__TokenNotSupported.selector, invalidTokenAddress)
        );
        diamond.unlockTokens(amount, user, invalidTokenAddress, messageWithNonce, signatures);
    }

    function testSetMinimumBridgeableAmount() public {
        uint248 newAmount = 200;
        messageWithNonce = getUniqueSignature(1);

        vm.expectEmit(true, false, false, false, address(diamond));
        emit ITokenManager.MinBridgeableAmountUpdated(newAmount);
        diamond.setMinimumBridgeableAmount(newAmount, messageWithNonce, signatures);

        assertEq(diamond.getMinimumBridgeableAmount(), newAmount);
    }

    function testSetMinimumBridgeableAmountInvalidMinBridgeableAmount() public {
        uint248 invalidAmount = 0;

        messageWithNonce = getUniqueSignature(1);
        vm.expectRevert(LibTokenManagerErrors.TokenManager__InvalidMinBridgeableAmount.selector);
        diamond.setMinimumBridgeableAmount(invalidAmount, messageWithNonce, signatures);
    }

    function testAddNewSupportedToken() public {
        address newToken = address(0x3);
        bool isSupported = diamond.isTokenSupported(newToken);
        assertFalse(isSupported);

        messageWithNonce = getUniqueSignature(1);
        diamond.addNewSupportedToken(newToken, messageWithNonce, signatures);

        isSupported = diamond.isTokenSupported(newToken);
        assertTrue(isSupported);
    }

    function testAddNewSupportedTokenAlreadyAdded() public {
        address newToken = address(0x3);
        bool isSupported = diamond.isTokenSupported(newToken);
        assertFalse(isSupported);

        messageWithNonce = getUniqueSignature(1);
        diamond.addNewSupportedToken(newToken, messageWithNonce, signatures);

        isSupported = diamond.isTokenSupported(newToken);
        assertTrue(isSupported);

        messageWithNonce = getUniqueSignature(1);
        vm.expectRevert(LibTokenManagerErrors.TokenManager__TokenAlreadyAdded.selector);
        diamond.addNewSupportedToken(newToken, messageWithNonce, signatures);
    }

    function testSetTreasuryAddress() public {
        address newTreasury = address(0x4);

        messageWithNonce = getUniqueSignature(1);
        diamond.setTreasuryAddress(newTreasury, messageWithNonce, signatures);

        messageWithNonce = getUniqueSignature(1);
        assertEq(diamond.getTreasuryAddress(messageWithNonce, signatures), newTreasury);
    }

    function testSetTreasuryAddressInvalidAddress() public {
        address invalidTreasuryAddress = address(0);

        messageWithNonce = getUniqueSignature(1);
        vm.expectRevert(LibTokenManagerErrors.TokenManager__InvalidTreasuryAddress.selector);
        diamond.setTreasuryAddress(invalidTreasuryAddress, messageWithNonce, signatures);
    }

    function testWithdrawTokenFunds() public {
        uint256 amount = diamond.getMinimumBridgeableAmount();

        mockToken.mint(address(user), amount);
        assertEq(mockToken.balanceOf(user), amount);

        vm.prank(user);
        mockToken.approve(address(diamond), amount);

        vm.prank(user);
        diamond.lockTokens(amount, address(mockToken), destinationChainId);

        assertEq(mockToken.balanceOf(user), 0, "User should have 0 tokens");

        messageWithNonce = getUniqueSignature(1);
        diamond.unlockTokens(amount, user, address(mockToken), messageWithNonce, signatures);

        uint256 fee = diamond.calculateFee(amount);
        uint256 amountWithoutFee = amount - fee;

        assertEq(mockToken.balanceOf(user), amountWithoutFee);
        assertEq(mockToken.balanceOf(address(diamond)), fee);

        diamond.withdrawTokenFunds(address(mockToken));

        assertEq(mockToken.balanceOf(address(diamond)), 0);

        messageWithNonce = getUniqueSignature(1);
        assertEq(mockToken.balanceOf(diamond.getTreasuryAddress(messageWithNonce, signatures)), fee);
    }

    function testWithdrawTokenFundsUnsupportedToken() public {
        address invalidTokenAddress = address(0);

        vm.expectRevert(
            abi.encodeWithSelector(LibTokenManagerErrors.TokenManager__TokenNotSupported.selector, invalidTokenAddress)
        );
        diamond.withdrawTokenFunds(invalidTokenAddress);
    }
}
