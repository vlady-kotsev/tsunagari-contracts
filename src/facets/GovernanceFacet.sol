// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IGovernance} from "../interfaces/IGovernance.sol";
import {LibGovernance} from "../libs/LibGovernance.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract GovernanceFacet is IGovernance {
    using EnumerableSet for EnumerableSet.AddressSet;

    error GovernanceFacet__InvalidMemberAddress();
    error GovernanceFacet__InvalidThreshold(uint256);
    error GovernanceFacet__FacetAlreadyInitialized();

    event MemberAdded(address);
    event ThresholdUpdated(uint256);

    function initGovernance(address[] memory members, uint256 threshold) external {
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
    }

    function addMember(address member) external {
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

    function setThreshold(uint256 threshold) external {
        LibGovernance.Storage storage gs = LibGovernance.getGovernanceStorage();
        if (threshold < 1 || threshold > gs.members.length()) {
            revert GovernanceFacet__InvalidThreshold(threshold);
        }
        gs.threshold = threshold;

        emit ThresholdUpdated(threshold);
    }
}
