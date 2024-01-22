// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0xB088741f11DB22A5DB2f2ddE851FD1c9DF10FA71;
address constant WORLD_ADDRESS = 0x008154C7A7084Af1A6Ee7252e428f358663d055F;

bytes32 constant ConcentrativeSoilObjectID = bytes32(keccak256("soil-concentrative"));
bytes32 constant DiffusiveSoilObjectID = bytes32(keccak256("soil-diffusive"));
bytes32 constant ProteinSoilObjectID = bytes32(keccak256("soil-protein"));
bytes32 constant ElixirSoilObjectID = bytes32(keccak256("soil-elixir"));

uint256 constant SOIL_MASS = 5;

bytes32 constant PlantObjectID = bytes32(keccak256("plant"));
bytes32 constant FarmerObjectID = bytes32(keccak256("farmer"));
