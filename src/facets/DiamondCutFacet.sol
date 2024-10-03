// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {LibDiamond} from "../libs/LibDiamond.sol";

contract DiamondCutFacet is IDiamondCut {
    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external {
        LibDiamond.diamondCut(_diamondCut, _init, _calldata);
    }
}
