// File: test/GovernanceFacet.t.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test} from "forge-std/Test.sol";
import {GovernanceFacet} from "../src/facets/GovernanceFacet.sol";
import {DeployGovernanceFacet} from "../script/GovernanceFacet.deploy.s.sol";
import {DeployDiamond} from "../script/Diamond.deploy.s.sol";
import {SignatureGenerator} from "../src/utils/SignatureGenerator.sol";
import {Diamond} from "../src/Diamond.sol";
import {IDiamond} from "../src/interfaces/IDiamond.sol";
import {GovernanceErrors} from "../src/facets/errors/GovernanceErrors.sol";

contract GovernanceFacetTest is Test, SignatureGenerator {
    IDiamond diamond;
    address[] members;
    address member1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address member2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address member3 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    function setUp() public {
        DeployDiamond dd = new DeployDiamond();
        Diamond d = dd.run(true);
        diamond = IDiamond(address(d));

        uint256 threshold = diamond.getThreshold();
        initSignatureGenerator(threshold);

        members = [member1, member2, member3];
    }

    function testRevertInitGovernanceInvalidThreshold() public {
        uint248 invalidThreshold = 4;

        DeployGovernanceFacet dgf = new DeployGovernanceFacet();
        GovernanceFacet governanceFacet = dgf.run();
        vm.expectRevert(
            abi.encodeWithSelector(GovernanceErrors.GovernanceFacet__InvalidThreshold.selector, invalidThreshold)
        );
        governanceFacet.initGovernance(members, invalidThreshold);
    }

    function testRevertInitGovernanceInvalidMember() public {
        address invalidMember = address(0);
        DeployGovernanceFacet dgf = new DeployGovernanceFacet();
        GovernanceFacet governanceFacet = dgf.run();
        members[0] = invalidMember;

        vm.expectRevert(GovernanceErrors.GovernanceFacet__InvalidMemberAddress.selector);
        governanceFacet.initGovernance(members, 2);
    }

    function testRevertOnInvalidThreshold() public {
        uint248 invalidThreshold = 4;
        messageWithNonce = getUniqueSignature();
        vm.expectRevert(
            abi.encodeWithSelector(GovernanceErrors.GovernanceFacet__InvalidThreshold.selector, invalidThreshold)
        );
        diamond.setThreshold(invalidThreshold, messageWithNonce, signatures);
    }

    function testRevertOnFacetAlreadyInitialized() public {
        vm.expectRevert(GovernanceErrors.GovernanceFacet__FacetAlreadyInitialized.selector);
        diamond.initGovernance(members, 2);
    }

    function testAddMember() public {
        messageWithNonce = getUniqueSignature();
        diamond.addMember(address(0x4), messageWithNonce, signatures);
    }

    function testAddMemberReverts() public {
        address invalidMember = address(0);
        messageWithNonce = getUniqueSignature();

        vm.expectRevert(GovernanceErrors.GovernanceFacet__InvalidMemberAddress.selector);
        diamond.addMember(invalidMember, messageWithNonce, signatures);
    }

    function testSetThreshold() public {
        messageWithNonce = getUniqueSignature();
        diamond.setThreshold(1, messageWithNonce, signatures);
        assertEq(diamond.getThreshold(), 1);
    }

    function testRevertOnInvalidThresholdOnSet() public {
        uint248 invalidThreshold = 4;
        messageWithNonce = getUniqueSignature();
        vm.expectRevert(
            abi.encodeWithSelector(GovernanceErrors.GovernanceFacet__InvalidThreshold.selector, invalidThreshold)
        );
        diamond.setThreshold(invalidThreshold, messageWithNonce, signatures);
    }
}
