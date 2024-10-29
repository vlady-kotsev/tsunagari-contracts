// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/// @title IGovernance
/// @notice Interface for governance operations
/// @dev This interface defines the core functions for initializing and managing governance
interface IGovernance {
    /// @notice Emitted when a new member is added to the governance
    /// @param member The address of the new member
    event MemberAdded(address member);

    /// @notice Emitted when the governance threshold is updated
    /// @param threshold The new threshold value
    event ThresholdUpdated(uint256 threshold);

    /// @notice Initializes the governance with a set of members and a threshold
    /// @param members An array of addresses representing the initial governance members
    /// @param threshold The initial threshold for governance decisions
    function initGovernance(address[] memory members, uint248 threshold) external;

    /// @notice Retrieves the current governance threshold
    /// @return The current threshold value
    function getThreshold() external returns (uint256);

    /// @notice Sets a new threshold for governance decisions
    /// @param threshold The new threshold value
    /// @param message The message that was signed by the governance members
    /// @param signatures An array of signatures from the governance members
    function setThreshold(uint248 threshold, bytes memory message, bytes[] memory signatures) external;

    /// @notice Adds a new member to the governance
    /// @param owner The address of the new member to be added
    /// @param message The message that was signed by the governance members
    /// @param signatures An array of signatures from the governance members
    function addMember(address owner, bytes memory message, bytes[] memory signatures) external;
}
