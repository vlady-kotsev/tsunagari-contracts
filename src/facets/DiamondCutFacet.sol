// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {LibDiamond} from "../libs/LibDiamond.sol";
import {SignatureChecker} from "../utils/SignatureChecker.sol";

contract DiamondCutFacet is IDiamondCut, SignatureChecker {
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
