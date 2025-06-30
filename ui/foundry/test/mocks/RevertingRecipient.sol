// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title RevertingRecipient
 * @dev A contract that reverts upon receiving ETH.
 */
contract RevertingRecipient {
    receive() external payable {
        revert("RevertingRecipient: Cannot receive ETH");
    }
}
