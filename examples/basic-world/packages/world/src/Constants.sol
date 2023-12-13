// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;
address constant SIMULATOR_ADDRESS = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

uint256 constant NUM_MAX_OBJECTS_INTERACTION_RUN = 100;
uint256 constant NUM_MAX_AGENT_ACTION_RADIUS = 1;

bytes32 constant AirObjectID = bytes32(keccak256("air"));
bytes32 constant DirtObjectID = bytes32(keccak256("dirt"));
bytes32 constant GrassObjectID = bytes32(keccak256("grass"));
bytes32 constant BedrockObjectID = bytes32(keccak256("bedrock"));
bytes32 constant BuilderObjectID = bytes32(keccak256("builder"));
