// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {SolarArrayComponentsNftFactory} from "src/SolarArrayComponentsNftFactory.sol";

contract DeploySolarArrayComponentsNftFactory is Script {
    function run() external returns (SolarArrayComponentsNftFactory) {
        vm.startBroadcast();
        SolarArrayComponentsNftFactory solarArrayComponentsNftFactory = new SolarArrayComponentsNftFactory();
        vm.stopBroadcast();
        return solarArrayComponentsNftFactory;
    }
}