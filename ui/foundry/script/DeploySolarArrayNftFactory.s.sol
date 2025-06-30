// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {SolarArrayNftFactory} from "src/SolarArrayNftFactory.sol";
import {ETHRelay} from "src/ETHRelay.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract DeploySolarArrayNftFactory is Script {
    function run() external returns (SolarArrayNftFactory) {
        // Fails "script failed: vm.readDir: the path broadcast is not allowed to be accessed for read operations"
        address mostRecentlyDeployedComponents = DevOpsTools.get_most_recent_deployment(
                "SolarArrayComponentsNftFactory",
                block.chainid
            );
        address mostRecentlyDeployedETHRelay = DevOpsTools.get_most_recent_deployment(
                "ETHRelay",
                block.chainid
            );
        console.log("most recent components factory",mostRecentlyDeployedComponents);
        console.log("most recent ETHRelay factory",mostRecentlyDeployedETHRelay);
        vm.startBroadcast();
        SolarArrayNftFactory solarArrayNftFactory = new SolarArrayNftFactory(mostRecentlyDeployedComponents,mostRecentlyDeployedETHRelay);
        vm.stopBroadcast();
        return solarArrayNftFactory;
    }
}