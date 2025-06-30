// SolarArrayVerifier.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SolarArrayStructs} from "./SolarArrayStructs.sol";
import {ISolarArrayComponentsNftFactory} from "./ISolarArrayComponentsNftFactory.sol";

/**
 * @title SolarArrayVerifier
 * @dev Library to verify Solar Array data.
 */
library SolarArrayVerifier {
    error TokenIdRequired();
    error TokenIdExists();
    error InvalidGeometry();
    error IntersectingSolarArrayGeometry();
    error ComponentsMissing();
    error MissingModules();
    error ModuleTiltExceeds180();
    error ModuleAzimuthExceeds360();
    error ComponentMissingQuantity();
    error ComponentTokenIdInvalid();
    error ComponentArrayNotSynced();

    /**
     * @dev Verifies the solar array details.
     */
    function verify(
        SolarArrayStructs.Array memory solarArray,
        SolarArrayStructs.Components[] memory components,
        ISolarArrayComponentsNftFactory componentsFactory,
        mapping(uint256 => SolarArrayStructs.Array) storage s_arrays,
        mapping(uint256 => uint256) storage arrayTokens,
        uint256 s_tokenCount
    ) internal view {
        if (solarArray.tokenId == 0) revert TokenIdRequired();
        if (componentsFactory.mintedTokens(solarArray.tokenId)) revert TokenIdExists();
        if (solarArray.geometry.length == 0) revert InvalidGeometry();

        uint256 numComponents = solarArray.modules.length +
            solarArray.inverters.length +
            solarArray.transformers.length +
            solarArray.lines.length +
            solarArray.batteries.length +
            solarArray.meters.length;

        if (numComponents != components.length) revert ComponentsMissing();
        if (solarArray.modules.length == 0) revert MissingModules();

        for (uint256 i = 0; i < s_tokenCount; i++) {
            if (
                solarArray.bbox[0] < s_arrays[arrayTokens[i]].bbox[2] &&
                s_arrays[arrayTokens[i]].bbox[0] < solarArray.bbox[2] &&
                solarArray.bbox[1] < s_arrays[arrayTokens[i]].bbox[3] &&
                s_arrays[arrayTokens[i]].bbox[1] < solarArray.bbox[3]
            ) {
                revert IntersectingSolarArrayGeometry();
            }
        }

        uint256 componentTokenId;
        uint256 indexOfComponents = 0;

        // Modules
        for (uint256 i = 0; i < solarArray.modules.length; i++) {
            if (solarArray.modules[i].quantity == 0) {
                revert ComponentMissingQuantity();
            }
            if (solarArray.modules[i].tilt > 180) {
                revert ModuleTiltExceeds180();
            }
            // What is actual range?  0<=360?
            if (solarArray.modules[i].azimuth > 360) {
                revert ModuleAzimuthExceeds360();
            }
            // Replace with oz's Strings equal
            if (
                keccak256(
                    abi.encodePacked(components[indexOfComponents].component)
                ) != keccak256(abi.encodePacked("module"))
            ) {
                revert ComponentArrayNotSynced();
            }

            componentTokenId = componentsFactory.generateTokenId(
                components[indexOfComponents].component,
                components[indexOfComponents].manufacturer,
                components[indexOfComponents].model
            );
            if (solarArray.modules[i].tokenId != componentTokenId) {
                revert ComponentTokenIdInvalid();
            }            

            indexOfComponents++;
        }

        // Inverters
        for (uint256 i = 0; i < solarArray.inverters.length; i++) {
            if (solarArray.inverters[i].quantity == 0) {
                revert ComponentMissingQuantity();
            }
            // Replace with oz's Strings equal
            if (
                keccak256(
                    abi.encodePacked(components[indexOfComponents].component)
                ) != keccak256(abi.encodePacked("inverter"))
            ) {
                revert ComponentArrayNotSynced();
            }

            componentTokenId = componentsFactory.generateTokenId(
                components[indexOfComponents].component,
                components[indexOfComponents].manufacturer,
                components[indexOfComponents].model
            );

            if (solarArray.inverters[i].tokenId != componentTokenId) {
                revert ComponentTokenIdInvalid();
            }
            indexOfComponents++;
        }

        // Batteries
        for (uint256 i = 0; i < solarArray.batteries.length; i++) {
            if (solarArray.batteries[i].quantity == 0) {
                revert ComponentMissingQuantity();
            }
            // Replace with oz's Strings equal
            if (
                keccak256(
                    abi.encodePacked(components[indexOfComponents].component)
                ) != keccak256(abi.encodePacked("battery"))
            ) {
                revert ComponentArrayNotSynced();
            }

            componentTokenId = componentsFactory.generateTokenId(
                components[indexOfComponents].component,
                components[indexOfComponents].manufacturer,
                components[indexOfComponents].model
            );

            if (solarArray.batteries[i].tokenId != componentTokenId) {
                revert ComponentTokenIdInvalid();
            }
            indexOfComponents++;
        }

        // Meters
        for (uint256 i = 0; i < solarArray.meters.length; i++) {
            // Replace with oz's Strings equal
            if (
                keccak256(
                    abi.encodePacked(components[indexOfComponents].component)
                ) != keccak256(abi.encodePacked("meter"))
            ) {
                revert ComponentArrayNotSynced();
            }

            componentTokenId = componentsFactory.generateTokenId(
                components[indexOfComponents].component,
                components[indexOfComponents].manufacturer,
                components[indexOfComponents].model
            );

            if (solarArray.meters[i].tokenId != componentTokenId) {
                revert ComponentTokenIdInvalid();
            }
            indexOfComponents++;
        }
        // Transformers
        for (uint256 i = 0; i < solarArray.transformers.length; i++) {
            // Replace with oz's Strings equal
            if (
                keccak256(
                    abi.encodePacked(components[indexOfComponents].component)
                ) != keccak256(abi.encodePacked("transformer"))
            ) {
                revert ComponentArrayNotSynced();
            }

            componentTokenId = componentsFactory.generateTokenId(
                components[indexOfComponents].component,
                components[indexOfComponents].manufacturer,
                components[indexOfComponents].model
            );

            if (solarArray.transformers[i].tokenId != componentTokenId) {
                revert ComponentTokenIdInvalid();
            }
            indexOfComponents++;
        }
        // Lines
        for (uint256 i = 0; i < solarArray.lines.length; i++) {
            // Replace with oz's Strings equal
            if (
                keccak256(
                    abi.encodePacked(components[indexOfComponents].component)
                ) != keccak256(abi.encodePacked("line"))
            ) {
                revert ComponentArrayNotSynced();
            }

            componentTokenId = componentsFactory.generateTokenId(
                components[indexOfComponents].component,
                components[indexOfComponents].manufacturer,
                components[indexOfComponents].model
            );

            if (solarArray.lines[i].tokenId != componentTokenId) {
                revert ComponentTokenIdInvalid();
            }
            indexOfComponents++;
        }
    }
}
