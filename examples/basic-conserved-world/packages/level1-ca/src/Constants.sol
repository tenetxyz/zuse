// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0xB088741f11DB22A5DB2f2ddE851FD1c9DF10FA71;

bytes32 constant AirVoxelID = bytes32(keccak256("air"));
bytes32 constant AirVoxelVariantID = bytes32(keccak256("air"));
bytes32 constant DirtVoxelID = bytes32(keccak256("dirt"));
bytes32 constant GrassVoxelID = bytes32(keccak256("grass"));
bytes32 constant BedrockVoxelID = bytes32(keccak256("bedrock"));
bytes32 constant StoneVoxelID = bytes32(keccak256("stone"));
bytes32 constant FaucetVoxelID = bytes32(keccak256("faucet"));
bytes32 constant BuilderVoxelID = bytes32(keccak256("builder"));
bytes32 constant RunnerVoxelID = bytes32(keccak256("runner"));

uint256 constant STARTING_STAMINA_FROM_FAUCET = 30000;
uint256 constant STARTING_HEALTH_FROM_FAUCET = 100;

int32 constant CHUNK_MAX_Y = 255;
int32 constant CHUNK_MIN_Y = -128;
int32 constant TILE_Y = 1;

// Terrain
enum Biome {
  Mountains,
  Desert,
  Forest,
  Savanna
}

uint256 constant SingletonID = 0x60D;

int32 constant STRUCTURE_CHUNK = 5;
int32 constant STRUCTURE_CHUNK_CENTER = STRUCTURE_CHUNK / 2 + 1;

int32 constant CHUNK = 16;
