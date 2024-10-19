// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface ITokenManager {
    function initTokenManager(uint248 minBridgeableAmount, address treasuryAddress) external;
    function lockTokens(uint256 amount, address tokenAddress) external;
    function unlockTokens(
        uint256 amount,
        address to,
        address tokenAddress,
        bytes memory message,
        bytes[] memory signatures
    ) external;
    function mintWrappedTokens(
        uint256 amount,
        address to,
        address wrappedTokenAddress,
        bytes memory message,
        bytes[] memory signatures
    ) external;
    function burnWrappedToken(uint256 amount, address tokenAddress) external;
    function getMinimumBridgeableAmount() external returns (uint256);
    function setMinimumBridgeableAmount(uint248 amount, bytes memory message, bytes[] memory signatures) external;
    function addNewSupportedToken(address tokenAddress, bytes memory message, bytes[] memory signatures) external;
    function withdrawTokenFunds(address tokenAddress) external;
    function getTreasuryAddress(bytes memory message, bytes[] memory signatures) external returns (address);
    function setTreasuryAddress(address treasuryAddress, bytes memory message, bytes[] memory signatures) external;
    function isTokenSupported(address tokenAddress) external returns (bool);
}
