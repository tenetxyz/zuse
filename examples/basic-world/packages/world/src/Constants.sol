// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;
address constant SIMULATOR_ADDRESS = 0x3BBbFE11925d965B343b806D7d7e32B5Ec126dF4;

uint256 constant NUM_MAX_OBJECTS_INTERACTION_RUN = 100;

bytes32 constant AirObjectID = bytes32(keccak256("air"));
bytes32 constant DirtObjectID = bytes32(keccak256("dirt"));
bytes32 constant GrassObjectID = bytes32(keccak256("grass"));
bytes32 constant BedrockObjectID = bytes32(keccak256("bedrock"));
bytes32 constant BuilderObjectID = bytes32(keccak256("builder"));
