// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IDiamondLoupe} from "../interfaces/IDiamondLoupe.sol";
import {LibDiamond} from "../libs/LibDiamond.sol";

contract DiamondLoupeFacet is IDiamondLoupe {
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

    function facetFunctionSelectors(address _facet)
        external
        view
        override
        returns (bytes4[] memory facetFunctionSelectors_)
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.getDiamondStorage();
        facetFunctionSelectors_ = ds.facetFunctionSelectors[_facet].functionSelectors;
    }

    function facetAddresses() external view override returns (address[] memory facetAddresses_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.getDiamondStorage();
        facetAddresses_ = ds.facetAddresses;
    }

    function facetAddress(bytes4 _functionSelector) external view override returns (address facetAddress_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.getDiamondStorage();
        facetAddress_ = ds.selectorToFacetAndPosition[_functionSelector].facetAddress;
    }
}
