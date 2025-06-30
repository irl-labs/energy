// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Solar Array Components Structs Library
/// @dev This contract defines the structures for various components of a solar array.

library SolarArrayStructs {

    /// @notice Represents a solar module.
    /// @param tokenId The unique identifier for the module component.
    /// @param quantity The number of panels in the module.
    /// @param tilt The tilt angle of the panels; 0<=tilt<=180.
    /// @param azimuth The azimuth angle of the panels 0<=azimuth<=360.
    /// @param tracking Indicates if the module has a tracking system to follow the sun.
    /// @param ground_mounted Indicates if the module is ground-mounted.
    struct Modules {
        uint256 tokenId;
        uint32 quantity;
        uint16 tilt;
        uint16 azimuth;
        bool tracking;
        bool ground_mounted;
    }

    /// @notice Represents an inverter in the solar array.
    /// @param tokenId The unique identifier for the inverter.
    /// @param quantity The number of inverters.
    /// @param micro_meter Indicates if the inverter is a micro-meter.
    /// @param multiple_phase_system Indicates if the system has multiple phases.
    /// @param dc_optimizer Indicates if the inverter has a DC optimizer.
    /// @param geometry The geometric location of each inverter's lat/lon in Morton Z-code format.
    struct Inverters {
        uint256 tokenId;
        uint16 quantity;
        bool micro_meter;
        bool multiple_phase_system;
        bool dc_optimizer;
        uint256[] geometry;
    }

    /// @notice Represents a transformer in the solar array.
    /// @param tokenId The unique identifier for the transformer.
    /// @param geometry The geometric location of the *one* transformer lat/lon in Morton Z-code format.
    struct Transformers {
        uint256 tokenId;
        uint256[] geometry;
    }

    /// @notice Represents a power line in the solar array.
    /// @param tokenId The unique identifier for the power line from transformer to the array inverters.
    /// @param circuit_id The identifier for the circuit.
    /// @param section_id The identifier for the section of the circuit.
    /// @param geometry The geometric location of the line endpoints lat/lon pairs in Morton Z-code format.
    struct Lines {
        uint256 tokenId;
        uint256[] geometry;
    }

    /// @notice Represents a meter in the solar array.
    /// @param tokenId The unique identifier for the meter.
    /// @param quantity The number of meters.
    /// @param geometry The geometric location of the meters lat/lon pairs in Morton Z-code format.
    struct Meters {
        uint256 tokenId;
        uint16 quantity;
        uint256[] geometry;
    }

    /// @notice Represents a battery in the solar array.
    /// @param tokenId The unique identifier for the battery.
    /// @param quantity The number of batteries.
    /// @param geometry The geometric location of the batteries in lat/lon pairs in Morton Z-code format.
    struct Batteries {
        uint256 tokenId;
        uint16 quantity;
        uint256[] geometry; 
    }

    /// @notice Represents a solar array with its components.
    /// @param tokenId The unique identifier for the array; morton code of geometry centroid
    /// @param modules The list of modules in the array.
    /// @param inverters The list of inverters in the array.
    /// @param transformers The list of transformers in the array.
    /// @param lines The list of lines in the array.
    /// @param meters The list of meters in the array.
    /// @param batteries The list of batteries in the array.
    /// @param geometry The geometric location (lat/lon) of the array in MultiPolygon Morton Z-code delta compressed format.
    struct Array {
        uint256 tokenId;
        bytes geometry;
        uint256[4] bbox;
        Modules[] modules;
        Inverters[] inverters;
        Batteries[] batteries;
        Meters[] meters;
        Transformers[] transformers;
        Lines[] lines;
    }

    /// @notice Represents a solar array with its components.
    /// @param tokenId The unique identifier for the array; morton code of geometry centroid
    struct Components {
        uint256 tokenId;
        uint256 collectionId;
        string component;
        string manufacturer;
        string model;
        uint32 supply;
    }

}
