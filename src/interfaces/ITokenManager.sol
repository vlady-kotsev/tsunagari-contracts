// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface ITokenManager {
    function initTokenManager(uint256 minBridgeableAmount) external;
    function lockTokens(uint256 amount, address tokenAddress) external;
    function unlockTokens(
        uint256 amount,
        address to,
        address tokenAddress,
        bytes32 messageHash,
        bytes[] memory signatures
    ) external;
    function mintWrappedTokens(
        uint256 amount,
        address to,
        address wrappedTokenAddress,
        bytes32 messageHash,
        bytes[] memory signatures
    ) external;
    function burnWrappedToken(uint256 amount, address tokenAddress) external;
    function getMinimumBridgeableAmount() external returns (uint256);
    function setMinimumBridgeableAmount(uint256 amount, bytes32 messageHash, bytes[] memory signatures) external;
    function addNewSupportedToken(address tokenAddress, bytes32 messageHash, bytes[] memory signatures) external;
}
