// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/// @title IDiamondLoupe
/// @notice Interface for diamond loupe functions in the Diamond Standard
/// @dev These functions are designed to provide introspection capabilities for diamonds
interface IDiamondLoupe {
    /// @notice A struct that represents a facet in the diamond
    /// @param facetAddress The address of the facet contract
    /// @param functionSelectors An array of function selectors supported by this facet
    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    /// @notice Get all facet information for a diamond
    /// @return facets_ An array of Facet structs containing all facet addresses and their function selectors
    function facets() external view returns (Facet[] memory facets_);

    /// @notice Get all the function selectors supported by a specific facet
    /// @param _facet The address of the facet to query
    /// @return facetFunctionSelectors_ An array of function selectors supported by the facet
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);

    /// @notice Get all the facet addresses used by a diamond
    /// @return facetAddresses_ An array of facet addresses
    function facetAddresses() external view returns (address[] memory facetAddresses_);

    /// @notice Get the facet address that supports a given function selector
    /// @param _functionSelector The function selector to query
    /// @return facetAddress_ The address of the facet that supports the given function
    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
}
