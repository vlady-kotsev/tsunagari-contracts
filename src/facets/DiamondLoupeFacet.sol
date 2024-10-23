// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IDiamondLoupe} from "../interfaces/IDiamondLoupe.sol";
import {LibDiamond} from "../libs/LibDiamond.sol";

/// @title DiamondLoupeFacet
/// @notice Implements diamond introspection functions from EIP-2535 Diamond standard
/// @dev This facet provides functions to inspect the facets of a diamond
contract DiamondLoupeFacet is IDiamondLoupe {
    /// @notice Get all facets and their selectors
    /// @return facets_ An array of Facet structs containing facet addresses and their function selectors
    function facets() external view override returns (Facet[] memory facets_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.getDiamondStorage();
        uint256 numFacets = ds.facetAddresses.length;
        facets_ = new Facet[](numFacets);
        for (uint256 i; i < numFacets; i++) {
            address facetAddress_ = ds.facetAddresses[i];
            facets_[i].facetAddress = facetAddress_;
            facets_[i].functionSelectors = ds.facetFunctionSelectors[facetAddress_].functionSelectors;
        }
    }

    /// @notice Get all function selectors supported by a specific facet
    /// @param _facet The facet address
    /// @return facetFunctionSelectors_ An array of function selectors
    function facetFunctionSelectors(address _facet)
        external
        view
        override
        returns (bytes4[] memory facetFunctionSelectors_)
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.getDiamondStorage();
        facetFunctionSelectors_ = ds.facetFunctionSelectors[_facet].functionSelectors;
    }

    /// @notice Get all facet addresses used by a diamond
    /// @return facetAddresses_ An array of facet addresses
    function facetAddresses() external view override returns (address[] memory facetAddresses_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.getDiamondStorage();
        facetAddresses_ = ds.facetAddresses;
    }

    /// @notice Get the facet that supports the given function selector
    /// @dev If facet is not found, returns address(0)
    /// @param _functionSelector The function selector to find the facet for
    /// @return facetAddress_ The address of the facet that supports the function selector
    function facetAddress(bytes4 _functionSelector) external view override returns (address facetAddress_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.getDiamondStorage();
        facetAddress_ = ds.selectorToFacetAndPosition[_functionSelector].facetAddress;
    }
}
