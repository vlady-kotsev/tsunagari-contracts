// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IDiamondCut} from "../interfaces/IDiamondCut.sol";

library LibDiamond {
    struct FacetFunctionSelectors {
        bytes4[] functionSelectors;
        uint16 facetAddressPosition; // position of facetAddress in facetAddresses array
    }

    struct FacetAddressAndPosition {
        address facetAddress;
        uint16 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array
    }

    struct DiamondStorage {
        bool initialized;
        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
        address[] facetAddresses;
    }

    bytes32 constant STORAGE_SLOT = keccak256("diamond.storage");

    event FunctionAdded(bytes4 functionSelector, address functionAddress);
    event FunctionReplaced(bytes4 functionSelector, address functionAddress);
    event FunctionRemoved(bytes4 functionSelector);

    error LibDiamond__InvalidFunctionSelector();
    error LibDiamond__InvalidFunctionAddress();
    error LibDiamond__FunctionAlreadyAdded();
    error LibDiamond__FunctionDoesntExist();
    error LibDiamond__InvalidCalldataLengthForAddressZero();
    error LibDiamond__InvalidCalldataLengthForNotAddressZero();
    error LibDiamond__InvalidExternalContractSize();
    error LibDiamond__InitFunctionReverted();

    function getDiamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = STORAGE_SLOT;
        assembly {
            ds.slot := position
        }
    }

    function diamondCut(IDiamondCut.FacetCut[] memory _diamondCut, address _init, bytes memory _calldata) internal {
        uint256 cutsLength = _diamondCut.length;
        for (uint256 i = 0; i < cutsLength;) {
            performBatchAction(_diamondCut[i].functionSelectors, _diamondCut[i].facetAddress, _diamondCut[i].action);
            assembly {
                i := add(1, i)
            }
        }
        initializeDiamondCut(_init, _calldata);
    }

    function performBatchAction(
        bytes4[] memory functionSelectors,
        address facetAddress,
        IDiamondCut.FacetCutAction action
    ) internal {
        uint256 selectorLength = functionSelectors.length;

        for (uint256 i = 0; i < selectorLength;) {
            if (action == IDiamondCut.FacetCutAction.Add) {
                addFunction(functionSelectors[i], facetAddress);
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                removeFunction(functionSelectors[i]);
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                replaceFunction(functionSelectors[i], facetAddress);
            }

            assembly {
                i := add(1, i)
            }
        }
    }

    function addFunction(bytes4 functionSelector, address facetAddress) internal {
        if (functionSelector == bytes4(0)) {
            revert LibDiamond__InvalidFunctionSelector();
        }
        if (facetAddress == address(0)) {
            revert LibDiamond__InvalidFunctionAddress();
        }

        DiamondStorage storage ds = getDiamondStorage();

        uint16 selectorPosition = uint16(ds.facetFunctionSelectors[facetAddress].functionSelectors.length);

        if (selectorPosition == 0) {
            enforceHasContractCode(facetAddress);
            ds.facetFunctionSelectors[facetAddress].facetAddressPosition = uint16(ds.facetAddresses.length);
            ds.facetAddresses.push(facetAddress);
        }

        ds.facetFunctionSelectors[facetAddress].functionSelectors.push(functionSelector);

        if (ds.selectorToFacetAndPosition[functionSelector].facetAddress != address(0)) {
            revert LibDiamond__FunctionAlreadyAdded();
        }
        ds.selectorToFacetAndPosition[functionSelector].facetAddress = facetAddress;
        ds.selectorToFacetAndPosition[functionSelector].functionSelectorPosition = selectorPosition;

        emit FunctionAdded(functionSelector, facetAddress);
    }

    function replaceFunction(bytes4 functionSelector, address facetAddress) internal {
        if (functionSelector == bytes4(0)) {
            revert LibDiamond__InvalidFunctionSelector();
        }
        if (facetAddress == address(0)) {
            revert LibDiamond__InvalidFunctionAddress();
        }
        removeFunction(functionSelector);
        addFunction(functionSelector, facetAddress);

        emit FunctionReplaced(functionSelector, facetAddress);
    }

    function removeFunction(bytes4 functionSelector) internal {
        if (functionSelector == bytes4(0)) {
            revert LibDiamond__InvalidFunctionSelector();
        }

        DiamondStorage storage ds = getDiamondStorage();

        if (ds.selectorToFacetAndPosition[functionSelector].facetAddress == address(0)) {
            revert LibDiamond__FunctionDoesntExist();
        }

        address facetAddress = ds.selectorToFacetAndPosition[functionSelector].facetAddress;

        uint256 facetSelectorLength = ds.facetFunctionSelectors[facetAddress].functionSelectors.length;
        uint16 functionSelectorPosition = ds.selectorToFacetAndPosition[functionSelector].functionSelectorPosition;

        if (facetSelectorLength == 1) {
            // remove whole facet
            uint16 facetPosition = ds.facetFunctionSelectors[facetAddress].facetAddressPosition;
            if (facetPosition != ds.facetAddresses.length - 1) {
                address temp = ds.facetAddresses[ds.facetAddresses.length - 1];
                ds.facetAddresses[ds.facetAddresses.length - 1] = ds.facetAddresses[facetPosition];
                ds.facetAddresses[facetPosition] = temp;
            }
            ds.facetAddresses.pop();
            delete ds.facetFunctionSelectors[facetAddress];
        } else if (facetSelectorLength > 1) {
            // Ensure the facet has more than one selector before removing
            // remove only selector from facet
            if (functionSelectorPosition == facetSelectorLength - 1) {
                // it's last
                ds.facetFunctionSelectors[facetAddress].functionSelectors.pop();
            } else {
                // it's not last, swap values
                bytes4 temp = ds.facetFunctionSelectors[facetAddress].functionSelectors[facetSelectorLength - 1];
                ds.facetFunctionSelectors[facetAddress].functionSelectors[facetSelectorLength - 1] =
                    ds.facetFunctionSelectors[facetAddress].functionSelectors[functionSelectorPosition];
                ds.facetFunctionSelectors[facetAddress].functionSelectors[functionSelectorPosition] = temp;

                // update the swapped function's selector position
                ds.selectorToFacetAndPosition[temp].functionSelectorPosition = functionSelectorPosition;
            }
        }
        delete ds.selectorToFacetAndPosition[functionSelector];
        emit FunctionRemoved(functionSelector);
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            if (_calldata.length != 0) {
                revert LibDiamond__InvalidCalldataLengthForAddressZero();
            }
        } else {
            if (_calldata.length < 1) {
                revert LibDiamond__InvalidCalldataLengthForNotAddressZero();
            }
            if (_init != address(this)) {
                enforceHasContractCode(_init);
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    revert(string(error));
                } else {
                    revert LibDiamond__InitFunctionReverted();
                }
            }
        }
    }

    function enforceHasContractCode(address _contract) internal view {
        bytes4 errorSelector = LibDiamond__InvalidExternalContractSize.selector;
        assembly {
            let contractSize := extcodesize(_contract)
            if lt(contractSize, 0x1) {
                mstore(0x00, errorSelector)
                revert(0x00, 0x4)
            }
        }
    }
}
