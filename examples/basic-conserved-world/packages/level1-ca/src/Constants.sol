// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;

bytes32 constant AirVoxelID = bytes32(keccak256("air"));
bytes32 constant AirVoxelVariantID = bytes32(keccak256("air"));
bytes32 constant DirtVoxelID = bytes32(keccak256("dirt"));
bytes32 constant GrassVoxelID = bytes32(keccak256("grass"));
bytes32 constant BedrockVoxelID = bytes32(keccak256("bedrock"));
bytes32 constant FaucetVoxelID = bytes32(keccak256("faucet"));
bytes32 constant CobblestoneBrickVoxelID = bytes32(keccak256("cobblestoneBrick"));
bytes32 constant CobblestoneShinglesVoxelID = bytes32(keccak256("cobblestoneShingles"));
bytes32 constant GlassVoxelID = bytes32(keccak256("glass"));
bytes32 constant LightVoxelID = bytes32(keccak256("light"));
bytes32 constant LimestoneVoxelID = bytes32(keccak256("limestone"));
bytes32 constant OakLeafVoxelID = bytes32(keccak256("oakLeaf"));
bytes32 constant StoneBrickVoxelID = bytes32(keccak256("stoneBrick"));
bytes32 constant StoneShinglesVoxelID = bytes32(keccak256("stoneShingles"));

uint256 constant STARTING_STAMINA_FROM_FAUCET = 15000;

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
