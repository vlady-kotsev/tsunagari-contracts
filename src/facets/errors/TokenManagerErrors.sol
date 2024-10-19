// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract TokenManagerErrors {
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
