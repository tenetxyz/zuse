// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;
address constant WORLD_ADDRESS = 0x0fe4223AD99dF788A6Dcad148eB4086E6389cEB6;

bytes32 constant ConcentrativeSoilObjectID = bytes32(keccak256("soil-concentrative"));
bytes32 constant DiffusiveSoilObjectID = bytes32(keccak256("soil-diffusive"));
bytes32 constant ProteinSoilObjectID = bytes32(keccak256("soil-protein"));
bytes32 constant ElixirSoilObjectID = bytes32(keccak256("soil-elixir"));

uint256 constant SOIL_MASS = 5;

bytes32 constant PlantObjectID = bytes32(keccak256("plant"));
bytes32 constant FarmerObjectID = bytes32(keccak256("farmer"));
