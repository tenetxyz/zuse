// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;
address constant SIMULATOR_ADDRESS = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

uint256 constant NUM_MAX_OBJECTS_INTERACTION_RUN = 1000;
uint256 constant NUM_MAX_UNIQUE_OBJECT_EVENT_HANDLERS_RUN = 15;
uint256 constant NUM_MAX_SAME_OBJECT_EVENT_HANDLERS_RUN = 25;
uint256 constant NUM_MAX_AGENT_ACTION_RADIUS = 1;

int32 constant SHARD_DIM = 100;
uint256 constant NUM_MAX_TOTAL_ENERGY_IN_SHARD = 100000000;
uint256 constant NUM_MAX_TOTAL_MASS_IN_SHARD = 100000000;

bytes32 constant AirObjectID = bytes32(keccak256("air"));
bytes32 constant DirtObjectID = bytes32(keccak256("dirt"));
bytes32 constant GrassObjectID = bytes32(keccak256("grass"));
bytes32 constant BedrockObjectID = bytes32(keccak256("bedrock"));
bytes32 constant BuilderObjectID = bytes32(keccak256("builder"));
bytes32 constant StoneObjectID = bytes32(keccak256("stone"));
bytes32 constant FaucetObjectID = bytes32(keccak256("faucet"));
bytes32 constant RunnerObjectID = bytes32(keccak256("runner"));

uint256 constant AIR_MASS = 0;
uint256 constant DIRT_MASS = 5;
uint256 constant GRASS_MASS = 5;
uint256 constant STONE_MASS = 5;
uint256 constant BEDROCK_MASS = 50;
