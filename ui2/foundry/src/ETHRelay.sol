// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title ETHRelay
 * @dev A contract to facilitate sending ETH from one EOA to another EOA.
 */
contract ETHRelay is ReentrancyGuard {

    /**
     * @dev Event emitted when ETH is successfully transferred.
     * @param sender The address initiating the transfer.
     * @param recipient The EOA receiving the ETH.
     * @param amount The amount of ETH transferred (in wei).
     */
    event ETHTransferred(address indexed sender, address indexed recipient, uint256 amount);
    error ETHTransferFailed();
    error NoETHSent();
    error ETHRecipientIsContract();

    /**
     * @dev Transfers a specified amount of ETH from the sender to a recipient EOA via the contract.
     * @param recipient The EOA address to send ETH to. Must be a non-contract address.
     *
     * Requirements:
     * - The sender must send exactly `amount` ETH along with the transaction.
     * - The `recipient` must not be a contract.
     */
    function transferETH(address payable recipient) external payable nonReentrant {

        uint256 ethAmount = msg.value;

        if(ethAmount == 0) revert NoETHSent();
        if(isContract(recipient)) revert ETHRecipientIsContract();

        // Transfer ETH to the recipient using call
        (bool success, ) = recipient.call{value: ethAmount}("");
        if(!success){revert ETHTransferFailed();}

        emit ETHTransferred(msg.sender, recipient, ethAmount);
    }

    /**
     * @dev Internal function to check if an address is a contract.
     * @param addr The address to check.
     * @return bool indicating whether the address is a contract.
     */
    function isContract(address addr) internal view returns (bool) {
        return addr.code.length > 0;
    }

    /**
     * @dev Fallback function to accept ETH sent directly to the contract without calling `transferETH`.
     */
    receive() external payable {
        // Optionally, you can emit an event or handle direct ETH transfers differently.
    }
}
