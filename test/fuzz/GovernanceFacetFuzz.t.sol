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

    function setUp() public {
        DeployGovernanceFacet dgf = new DeployGovernanceFacet();
        governanceFacet = dgf.run();

        DeployDiamond dd = new DeployDiamond();
        Diamond d = dd.run(true);
        diamond = IDiamond(address(d));
        uint256 threshold = diamond.getThreshold();
        initSignatureGenerator(threshold);
    }

    function testFuzzInitGovernance(address member1, address member2, address member3) public {
        address[] memory members = new address[](3);
        members[0] = member1;
        members[1] = member2;
        members[2] = member3;

        vm.assume(member1 != address(0) && member2 != address(0) && member3 != address(0));

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
        diamond.addMember(member, messageWithNonce, signatures);
    }
}
