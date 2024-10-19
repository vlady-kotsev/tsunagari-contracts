// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract GovernanceErrors {
    error GovernanceFacet__InvalidMemberAddress();
    error GovernanceFacet__InvalidThreshold(uint256);
    error GovernanceFacet__FacetAlreadyInitialized();
}
