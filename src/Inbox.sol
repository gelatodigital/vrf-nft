// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {GelatoVRFConsumer} from "./Consumer.sol";

/// @title GelatoVRFInbox
/// @dev Contract for managing requests for Verifiable Random Function (VRF) randomness callbacks.
contract GelatoVRFInbox {
    /// @notice Event emitted when a randomness request is made.
    /// @param callback The GelatoVRFConsumer contract to receive the randomness callback.
    /// @param sender The address of the sender who initiated the request.
    /// @param data Additional data associated with the request.
    event RequestedRandomness(
        GelatoVRFConsumer callback,
        address indexed sender,
        bytes data
    );

    /// @notice Request VRF randomness callback.
    /// @dev Emits the RequestedRandomness event to signal the request for randomness.
    /// @param callback The GelatoVRFConsumer contract that will receive the randomness callback.
    /// @param data Additional data associated with the request.
    function requestRandomness(
        GelatoVRFConsumer callback,
        bytes calldata data
    ) external {
        emit RequestedRandomness(callback, msg.sender, data);
    }
}