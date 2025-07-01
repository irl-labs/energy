// IETHRelay.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IETHRelay
 * @dev Interface for ETHRelay contract to handle ETH transfers.
 */
interface IETHRelay {
    function transferETH(address payable recipient) external payable;
}
