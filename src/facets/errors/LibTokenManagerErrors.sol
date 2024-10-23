// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/// @title LibTokenManagerErrors
/// @notice This library contains custom errors for the TokenManagerFacet contract
/// @dev These errors are used to provide more specific information about failures in the TokenManagerFacet
library LibTokenManagerErrors {
    error TokenManager__InvalidTransferAmount(uint256);
    error TokenManager__InvalidMintAmount();
    error TokenManager__InvalidWrappedTokenAddress();
    error TokenManager__InvalidMintReceiverAddress();
    error TokenManager__InvalidBurnTokenAddress();
    error TokenManager__InvalidUnlockAmount();
    error TokenManager__InvalidUnlockReceiverAddress();
    error TokenManager__InvalidMinBridgeableAmount();
    error TokenManager__FacetAlreadyInitialized();
    error TokenManager__TokenAlreadyAdded();
    error TokenManager__TokenNotSupported(address);
    error TokenManager__InvalidTreasuryAddress();
}
