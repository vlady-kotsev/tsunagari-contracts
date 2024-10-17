// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test} from "forge-std/Test.sol";
import {DeployDiamond} from "../script/Diamond.deploy.s.sol";
import {Diamond} from "../src/Diamond.sol";
import {IDiamond} from "../src/interfaces/IDiamond.sol";
import {LibSignatureChecker} from "../src/libs/LibSignatureChecker.sol";
import {SignatureGenerator} from "../src/utils/SignatureGenerator.sol";

contract SignatureCheckerTest is Test, SignatureGenerator {
    IDiamond diamond;

    function setUp() public {
        DeployDiamond dd = new DeployDiamond();
        Diamond d = dd.run(true);
        diamond = IDiamond(address(d));
        uint256 threshold = diamond.getThreshold();
        initSignatureGenerator(threshold);
    }

    function testInvalidMessageHashAlreadyUsed() public {
        messageWithNonce = getUniqueSignature();
        diamond.addNewSupportedToken(address(1), messageWithNonce, signatures);

        vm.expectRevert(LibSignatureChecker.LibSignatureChecker__InvalidMessageHashAlreadyUsed.selector);
        diamond.addNewSupportedToken(address(1), messageWithNonce, signatures);
    }

    function testInvalidSignatureLength() public {
        messageWithNonce = getUniqueSignature();
        signatures[0] = hex"0123";

        vm.expectRevert(LibSignatureChecker.LibSignatureChecker__InvalidSignatureLength.selector);
        diamond.addNewSupportedToken(address(1), messageWithNonce, signatures);
    }

    function testInvalidSignatureCount() public {
        messageWithNonce = getUniqueSignature();
        signatures = new bytes[](0);

        vm.expectRevert(
            abi.encodeWithSelector(LibSignatureChecker.LibSignatureChecker__InvalidSignaturesCount.selector, 0)
        );
        diamond.addNewSupportedToken(address(1), messageWithNonce, signatures);
    }

    function testSingaturesNotUnique() public {
        messageWithNonce = getUniqueSignature();
        diamond.setThreshold(2, messageWithNonce, signatures);

        messageWithNonce = getUniqueSignature();
        bytes memory signature = signatures[0];
        signatures = new bytes[](2);
        signatures[0] = signature;
        signatures[1] = signature;

        vm.expectRevert(LibSignatureChecker.LibSignatureChecker__InvalidSignaturesNotUnique.selector);
        diamond.addNewSupportedToken(address(1), messageWithNonce, signatures);
    }

    function testRecoveredAddressNotMember() public {
        getUniqueSignature();

        vm.expectRevert(LibSignatureChecker.LibSignatureChecker__RecoveredAddressNotMember.selector);
        diamond.addNewSupportedToken(address(1), hex"00", signatures);
    }

    function testUint2StrWithZero() public pure {
        string memory actual = LibSignatureChecker.uint2str(0);
        string memory expected = "0";

        assertEq(expected, actual);
    }
}
