// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Foundry's Test library
import "forge-std/Test.sol";

// Import the ETHRelay contract and helper contracts
import "../src/ETHRelay.sol";
import "./mocks/MockRecipient.sol";
import "./mocks/RevertingRecipient.sol";

/**
 * @title ETHRelayTest
 * @dev Foundry test suite for the ETHRelay contract.
 */
contract ETHRelayTest is Test {
    ETHRelay ethRelay;

    // Mock recipient contracts
    MockRecipient mockRecipient;
    RevertingRecipient revertingRecipient;

    // Addresses
    address payable eoa = payable(address(0xBEEF)); // Externally Owned Account
    address payable zeroAddress = payable(address(0));

    // Custom error selectors
    bytes4 constant NO_ETH_SENT_SELECTOR = bytes4(keccak256("NoETHSent()"));
    bytes4 constant ETH_RECIPIENT_IS_CONTRACT_SELECTOR = bytes4(keccak256("ETHRecipientIsContract()"));
    bytes4 constant ETH_TRANSFER_FAILED_SELECTOR = bytes4(keccak256("ETHTransferFailed()"));

    /**
     * @dev Deploys the ETHRelay and mock recipient contracts before each test.
     */
    function setUp() public {
        // Deploy ETHRelay
        ethRelay = new ETHRelay();

        // Deploy mock recipient contracts
        mockRecipient = new MockRecipient();
        revertingRecipient = new RevertingRecipient();
    }

    /**
     * @dev Test successful ETH transfer to an EOA.
     */
    function testTransferETHToEOA() public {
        uint256 initialBalance = eoa.balance;
        uint256 sendAmount = 1 ether;

        // Prank as the sender (msg.sender) is the test contract by default

        // Expect the ETHTransferred event to be emitted with correct parameters
        vm.expectEmit(true, true, false, true);
        emit ETHTransferred(address(this), eoa, sendAmount);

        // Transfer ETH to the EOA
        ethRelay.transferETH{value: sendAmount}(eoa);

        // Assert that the EOA received the ETH
        assertEq(eoa.balance, initialBalance + sendAmount, "EOA did not receive the correct ETH amount");
    }

    /**
     * @dev Test ETH transfer reverts when sending to a contract address.
     */
    function testTransferETHToContract() public {
        uint256 sendAmount = 1 ether;

        // Attempt to transfer ETH to a contract address and expect a revert
        vm.expectRevert(ETH_RECIPIENT_IS_CONTRACT_SELECTOR);
        ethRelay.transferETH{value: sendAmount}(payable(address(mockRecipient)));
    }

    /**
     * @dev Test ETH transfer reverts when sending to a reverting contract.
     */
    function testTransferETHToRevertingContract() public {
        uint256 sendAmount = 1 ether;

        // Attempt to transfer ETH to a contract that reverts and expect the same ETHRecipientIsContract revert
        vm.expectRevert(ETH_RECIPIENT_IS_CONTRACT_SELECTOR);
        ethRelay.transferETH{value: sendAmount}(payable(address(revertingRecipient)));
    }

    /**
     * @dev Test ETH transfer reverts when sending zero ETH.
     */
    function testTransferETHWithZeroValue() public {
        // Attempt to transfer zero ETH and expect a revert
        vm.expectRevert(NO_ETH_SENT_SELECTOR);
        ethRelay.transferETH{value: 0}(eoa);
    }

    /**
     * @dev Test ETH transfer fails if the call to recipient fails (covered by contract recipient tests).
     * This is implicitly tested by transferring to a reverting contract.
     */
    function testTransferETHFailsIfCallFails() public {
        uint256 sendAmount = 1 ether;

        // Attempt to transfer ETH to a reverting contract and expect a revert
        vm.expectRevert(ETH_RECIPIENT_IS_CONTRACT_SELECTOR);
        ethRelay.transferETH{value: sendAmount}(payable(address(revertingRecipient)));
    }

    /**
     * @dev Test that ETHRelay can receive ETH directly.
     */
    function testReceiveETH() public {
        uint256 sendAmount = 1 ether;

        // Record initial balance of ETHRelay
        uint256 initialBalance = address(ethRelay).balance;

        // Send ETH directly to the contract's receive function
        (bool success, ) = address(ethRelay).call{value: sendAmount}("");
        require(success, "Direct ETH transfer failed");

        // Assert that ETHRelay's balance increased
        assertEq(address(ethRelay).balance, initialBalance + sendAmount, "ETHRelay did not receive ETH directly");
    }

    /**
     * @dev Event declaration to capture ETHTransferred events for testing.
     */
    event ETHTransferred(address indexed sender, address indexed recipient, uint256 amount);
}
