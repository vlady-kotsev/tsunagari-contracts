// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {LibDiamond} from "../libs/LibDiamond.sol";
import {SignatureChecker} from "../utils/SignatureChecker.sol";

/// @title DiamondCutFacet
/// @notice Implements diamond cut functionality for upgrading the diamond proxy
/// @dev This contract is part of a diamond proxy system 
contract DiamondCutFacet is IDiamondCut, SignatureChecker {
    /// @notice Performs a diamond cut, which updates the diamond's function selectors
    /// @dev This function can only be called if signed by all members
    /// @param _diamondCut An array of FacetCut structs containing the facet addresses and function selectors
    /// @param _init The address of the contract or facet to execute _calldata
    /// @param _calldata A function call, including function selector and arguments, to execute on _init
    /// @param message The message that was signed by the members
    /// @param signatures An array of signatures from all members
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata,
        bytes memory message,
        bytes[] memory signatures
    ) external enforceIsSignedByAllMembers(message, signatures) {
        LibDiamond.diamondCut(_diamondCut, _init, _calldata);
    }
}
