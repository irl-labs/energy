// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SolarArrayStructs.sol";

library SolarArraySetters {

    /// @notice Set the solar array itself
    function setSolarArray(
        SolarArrayStructs.Array storage array, 
        SolarArrayStructs.Array memory solarArray
    ) external {
        array.tokenId = solarArray.tokenId;
        array.geometry = solarArray.geometry;
        array.bbox = solarArray.bbox;
    }

    /// @notice Add a module to the array
    function addModuleToArray(
        SolarArrayStructs.Array storage array,
        SolarArrayStructs.Modules memory module
    ) external {
        SolarArrayStructs.Modules memory newModule = SolarArrayStructs.Modules(
            module.tokenId,
            module.quantity,
            module.tilt,
            module.azimuth,
            module.tracking,
            module.ground_mounted
        );
        array.modules.push(newModule);
    }

    /// @notice Add an inverter to the array
    function addInverterToArray(
        SolarArrayStructs.Array storage array,
        SolarArrayStructs.Inverters memory inverter
    ) external {
        SolarArrayStructs.Inverters memory newInverter = SolarArrayStructs.Inverters(
            inverter.tokenId,
            inverter.quantity,
            inverter.micro_meter,
            inverter.multiple_phase_system,
            inverter.dc_optimizer,
            inverter.geometry
        );
        array.inverters.push(newInverter);
    }

    /// @notice Add a battery to the array
    function addBatteryToArray(
        SolarArrayStructs.Array storage array,
        SolarArrayStructs.Batteries memory battery
    ) external {
        array.batteries.push(SolarArrayStructs.Batteries(
            battery.tokenId,
            battery.quantity,
            battery.geometry
        ));
    }

    /// @notice Add a meter to the array
    function addMeterToArray(
        SolarArrayStructs.Array storage array,
        SolarArrayStructs.Meters memory meter
    ) external {
        array.meters.push(SolarArrayStructs.Meters(
            meter.tokenId,
            meter.quantity,
            meter.geometry
        ));
    }

    /// @notice Add a transformer to the array
    function addTransformerToArray(
        SolarArrayStructs.Array storage array,
        SolarArrayStructs.Transformers memory transformer
    ) external {
        array.transformers.push(
            SolarArrayStructs.Transformers(
                transformer.tokenId,
                transformer.geometry
            )
        );
    }

    /// @notice Add a power line to the array
    function addLineToArray(
        SolarArrayStructs.Array storage array,
        SolarArrayStructs.Lines memory line
    ) external {
        array.lines.push(SolarArrayStructs.Lines(
            line.tokenId,
            line.geometry
        ));
    }

}
