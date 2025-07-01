// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ETHRelay} from "src/ETHRelay.sol";

contract DeployETHRelay is Script {
    function run() external returns (ETHRelay) {
        vm.startBroadcast();
        ETHRelay ethRelay = new ETHRelay();
        vm.stopBroadcast();
        return ethRelay;
    }
}