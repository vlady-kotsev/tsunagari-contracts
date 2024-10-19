// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IGovernance} from "../interfaces/IGovernance.sol";
import {LibGovernance} from "../libs/LibGovernance.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {SignatureChecker} from "../utils/SignatureChecker.sol";
import {GovernanceErrors} from "./errors/GovernanceErrors.sol";

contract GovernanceFacet is IGovernance, SignatureChecker, GovernanceErrors {
    using EnumerableSet for EnumerableSet.AddressSet;

    event MemberAdded(address);
    event ThresholdUpdated(uint256);

    function initGovernance(address[] memory members, uint248 threshold) external {
        LibGovernance.Storage storage gs = LibGovernance.getGovernanceStorage();
        if (gs.initialized) {
            revert GovernanceFacet__FacetAlreadyInitialized();
        }
        uint256 membersLength = members.length;
        if (threshold < 1 || threshold > membersLength) {
            revert GovernanceFacet__InvalidThreshold(threshold);
        }
        gs.threshold = threshold;

        for (uint256 i = 0; i < membersLength;) {
            if (members[i] == address(0)) {
                revert GovernanceFacet__InvalidMemberAddress();
            }
            gs.members.add(members[i]);
            assembly {
                i := add(i, 1)
            }
        }
        gs.initialized = true;
    }

    function addMember(address member, bytes memory message, bytes[] memory signatures)
        external
        enforceIsSignedByAllMembers(message, signatures)
    {
        if (member == address(0)) {
            revert GovernanceFacet__InvalidMemberAddress();
        }
        LibGovernance.Storage storage gs = LibGovernance.getGovernanceStorage();
        gs.members.add(member);

        emit MemberAdded(member);
    }

    function getThreshold() external view returns (uint256) {
        LibGovernance.Storage storage gs = LibGovernance.getGovernanceStorage();
        return gs.threshold;
    }

    function setThreshold(uint248 threshold, bytes memory message, bytes[] memory signatures)
        external
        enforceIsSignedByAllMembers(message, signatures)
    {
        LibGovernance.Storage storage gs = LibGovernance.getGovernanceStorage();
        if (threshold < 1 || threshold > gs.members.length()) {
            revert GovernanceFacet__InvalidThreshold(threshold);
        }
        gs.threshold = threshold;

        emit ThresholdUpdated(threshold);
    }
}
