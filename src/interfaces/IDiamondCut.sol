// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface IDiamondCut {
    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);

    enum FacetCutAction {
        Add,
        Replace,
        Remove
    }

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external;
}
