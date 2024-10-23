// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IGovernance} from "../interfaces/IGovernance.sol";
import {LibGovernance} from "../libs/LibGovernance.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {SignatureChecker} from "../utils/SignatureChecker.sol";
import {LibGovernanceErrors} from "./errors/LibGovernanceErrors.sol";

/// @title GovernanceFacet
/// @notice Manages governance operations including member management and threshold settings
/// @dev Implements the IGovernance interface and uses the Diamond pattern for upgradability
contract GovernanceFacet is IGovernance, SignatureChecker {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @notice Emitted when a new member is added to the governance
    /// @param member The address of the new member
    event MemberAdded(address member);

    /// @notice Emitted when the governance threshold is updated
    /// @param threshold The new threshold value
    event ThresholdUpdated(uint256 threshold);

    /// @notice Initializes the governance with a set of members and a threshold
    /// @param members An array of initial member addresses
    /// @param threshold The initial threshold for governance decisions
    /// @dev Can only be called once
    function initGovernance(address[] memory members, uint248 threshold) external {
        LibGovernance.Storage storage gs = LibGovernance.getGovernanceStorage();
        if (gs.initialized) {
            revert LibGovernanceErrors.GovernanceFacet__FacetAlreadyInitialized();
        }
        uint256 membersLength = members.length;
        if (threshold < 1 || threshold > membersLength) {
            revert LibGovernanceErrors.GovernanceFacet__InvalidThreshold(threshold);
        }
        gs.threshold = threshold;

        for (uint256 i = 0; i < membersLength;) {
            if (members[i] == address(0)) {
                revert LibGovernanceErrors.GovernanceFacet__InvalidMemberAddress();
            }
            bool isUnique = gs.members.add(members[i]);
            if (!isUnique) {
                revert LibGovernanceErrors.GovernanceFacet__MemberAlreadyAdded();
            }

            assembly {
                i := add(i, 1)
            }
        }
        gs.initialized = true;
    }

    /// @notice Adds a new member to the governance
    /// @param member The address of the new member to add
    /// @param message The message to be signed
    /// @param signatures The signatures of the current members
    /// @dev Requires signatures from all current members
    function addMember(address member, bytes memory message, bytes[] memory signatures)
        external
        enforceIsSignedByAllMembers(message, signatures)
    {
        if (member == address(0)) {
            revert LibGovernanceErrors.GovernanceFacet__InvalidMemberAddress();
        }
        LibGovernance.Storage storage gs = LibGovernance.getGovernanceStorage();
        bool isUnique = gs.members.add(member);
        if (!isUnique) {
            revert LibGovernanceErrors.GovernanceFacet__MemberAlreadyAdded();
        }

        emit MemberAdded(member);
    }

    /// @notice Retrieves the current governance threshold
    /// @return The current threshold value
    function getThreshold() external view returns (uint256) {
        LibGovernance.Storage storage gs = LibGovernance.getGovernanceStorage();
        return gs.threshold;
    }

    /// @notice Updates the governance threshold
    /// @param threshold The new threshold value
    /// @param message The message to be signed
    /// @param signatures The signatures of the current members
    /// @dev Requires signatures from all current members
    function setThreshold(uint248 threshold, bytes memory message, bytes[] memory signatures)
        external
        enforceIsSignedByAllMembers(message, signatures)
    {
        LibGovernance.Storage storage gs = LibGovernance.getGovernanceStorage();
        if (threshold < 1 || threshold > gs.members.length()) {
            revert LibGovernanceErrors.GovernanceFacet__InvalidThreshold(threshold);
        }
        gs.threshold = threshold;

        emit ThresholdUpdated(threshold);
    }
}
