// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MockRecipient
 * @dev A contract that accepts ETH and emits an event upon receipt.
 */
contract MockRecipient {
    event Received(address sender, uint256 amount);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
