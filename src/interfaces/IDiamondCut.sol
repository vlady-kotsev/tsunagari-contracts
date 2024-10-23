// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/// @title IDiamondCut
/// @notice Interface for diamond cuts in the Diamond Standard
/// @dev Defines the structure and function for modifying a diamond's facets
interface IDiamondCut {
    /// @notice Emitted when a diamond cut is executed
    /// @param _diamondCut An array of FacetCut structs containing the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments, to execute on _init
    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);

    /// @notice Defines the possible actions for a facet cut
    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }

    /// @notice Struct for a single facet cut
    /// @param facetAddress The address of the facet to add, replace, or remove
    /// @param action The action to perform (Add, Replace, or Remove)
    /// @param functionSelectors An array of function selectors to add, replace, or remove
    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    /// @notice Performs a diamond cut
    /// @param _diamondCut An array of FacetCut structs containing the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments, to execute on _init
    /// @param message The message that was signed by
    /// @param signatures An array of signatures for the message
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata,
        bytes memory message,
        bytes[] memory signatures
    ) external;
}
