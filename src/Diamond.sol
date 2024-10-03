// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LibDiamond} from "./libs/LibDiamond.sol";
import {IDiamondCut} from "./interfaces/IDiamondCut.sol";

contract Diamond {
    error Diamond__FacetDoesntExist(bytes4);

    constructor(IDiamondCut.FacetCut[] memory _diamondCut) {
        LibDiamond.diamondCut(_diamondCut, address(0), new bytes(0));
    }

    receive() external payable {}

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
