// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibDiamond} from "./libs/LibDiamond.sol";
import {IDiamondCut} from "./interfaces/IDiamondCut.sol";

/// @title Diamond
/// @notice Implementation of the diamond proxy pattern
/// @dev This contract is the main entry point for the diamond proxy
contract Diamond {
    /// @notice Error thrown when a function is called on a non-existent facet
    /// @param selector The function selector that doesn't exist
    error Diamond__FacetDoesntExist(bytes4 selector);

    /// @notice Constructs the Diamond contract
    /// @param _diamondCut An array of FacetCut structs defining the initial facets
    constructor(IDiamondCut.FacetCut[] memory _diamondCut) {
        LibDiamond.diamondCut(_diamondCut, address(0), new bytes(0));
    }

    /// @notice Fallback function to handle Ether transfers
    /// @dev This function is payable and allows the contract to receive Ether
    receive() external payable {}

    /// @notice Fallback function to delegate calls to facets
    /// @dev This function is payable and delegates calls to the appropriate facet
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds = LibDiamond.getDiamondStorage();
        address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
        if (facet == address(0)) {
            revert Diamond__FacetDoesntExist(msg.sig);
        }
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
