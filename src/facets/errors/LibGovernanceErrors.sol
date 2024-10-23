// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/// @title LibGovernanceErrors
/// @notice This library contains custom errors for the GovernanceFacet contract
/// @dev These errors are used to provide more specific information about failures in the GovernanceFacet
library LibGovernanceErrors {
    error GovernanceFacet__InvalidMemberAddress();
    error GovernanceFacet__InvalidThreshold(uint256);
    error GovernanceFacet__FacetAlreadyInitialized();
    error GovernanceFacet__MemberAlreadyAdded();
}
