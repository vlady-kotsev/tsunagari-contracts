// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Diamond} from "../../src/Diamond.sol";
import {IDiamond} from "../../src/interfaces/IDiamond.sol";
import {DeployDiamond} from "../../script/Diamond.deploy.s.sol";
import {GovernanceFacet} from "../../src/facets/GovernanceFacet.sol";
import {SignatureGenerator} from "../../src/utils/SignatureGenerator.sol";
import {DeployGovernanceFacet} from "../../script/GovernanceFacet.deploy.s.sol";
import {GovernanceFacet} from "../../src/facets/GovernanceFacet.sol";

contract GovernanceFacetFuzzTest is Test, SignatureGenerator {
    IDiamond diamond;
    GovernanceFacet governanceFacet;
    address member1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address member2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address member3 = 0x4747b7f5c40599E1C5CF5a72C535D953B64916b6;

    function setUp() public {
        DeployGovernanceFacet dgf = new DeployGovernanceFacet();
        governanceFacet = dgf.run();

        DeployDiamond dd = new DeployDiamond();
        Diamond d = dd.run(true);
        diamond = IDiamond(address(d));
        uint256 threshold = diamond.getThreshold();
        initSignatureGenerator(threshold);
    }

    function testFuzzInitGovernance(address m1, address m2, address m3) public {
        address[] memory members = new address[](3);
        members[0] = m1;
        members[1] = m2;
        members[2] = m3;

        vm.assume(m1 != address(0) && m2 != address(0) && m3 != address(0));
        vm.assume(m1 != m2 && m1 != m3 && m2 != m3);

        governanceFacet.initGovernance(members, 2);
        assertEq(diamond.getThreshold(), 1);
    }

    function testFuzzSetThreshold(uint256 threshold) public {
        vm.assume(threshold > 0 && threshold <= 1000);
        address[] memory members = new address[](threshold);
        for (uint256 i = 0; i < members.length; i++) {
            members[i] = address(uint160(i + 1));
        }

        messageWithNonce = getUniqueSignature();
        diamond.setThreshold(1, messageWithNonce, signatures);
        assertEq(diamond.getThreshold(), 1);
    }

    function testFuzzAddMember(address member) public {
        messageWithNonce = getUniqueSignature();
        vm.assume(member != address(0));
        vm.assume(member != member1 && member != member2 && member != member3);
        diamond.addMember(member, messageWithNonce, signatures);
    }
}
