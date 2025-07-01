// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../src/IETHRelay.sol";

/**
 * @title MockETHRelay
 * @dev A mock implementation of the IETHRelay interface for testing purposes.
 */
contract MockETHRelay is IETHRelay {
    event ETHTransferred(address indexed sender, address indexed recipient, uint256 amount);

    function transferETH(address payable recipient) external payable override {
        require(recipient != address(0), "Recipient cannot be zero address");
        (bool success, ) = recipient.call{value: msg.value}("");
        require(success, "ETH transfer failed");
        emit ETHTransferred(msg.sender, recipient, msg.value);
    }
}
