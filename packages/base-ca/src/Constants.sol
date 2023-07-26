// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

address constant REGISTRY_WORLD = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
bytes32 constant EMPTY_ID = bytes32(0x0);

bytes32 constant AirVoxelID = bytes32(keccak256("air"));
bytes32 constant AirVoxelVariantID = bytes32(keccak256("air"));

bytes32 constant DirtVoxelID = bytes32(keccak256("dirt"));
bytes32 constant DirtVoxelVariantID = bytes32(keccak256("dirt"));
string constant DirtTexture = "bafkreibzraiuk6hgngtfczn57sivuqf3nv77twi6g3ftas2umjnbf6jefe";
string constant DirtUVWrap = "bafkreifbshwckn4pgw5ew2obz3i74eujzpcomatus5gu2tk7mms373gqme";

bytes32 constant GrassVoxelID = bytes32(keccak256("grass"));
bytes32 constant GrassVoxelVariantID = bytes32(keccak256("grass"));
string constant GrassTexture = "bafkreifmvm3yxzbkzcb2r7m6gavjhe22n4p3o36lz2ypkgf5v6i6zzhv4a";
string constant GrassSideTexture = "bafkreibp5wefex2cunqz5ffwt3ucw776qthwl6y6pswr2j2zuzldrv6bqa";
string constant GrassUVWrap = "bafkreihaagdyqnbie3eyx6upmoul2zb4qakubxg6bcha6k5ebp4fbsd3am";

bytes32 constant BedrockVoxelID = bytes32(keccak256("bedrock"));
bytes32 constant BedrockVoxelVariantID = bytes32(keccak256("bedrock"));
string constant BedrockTexture = "bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a";
string constant BedrockUVWrap = "bafkreihdit6glam7sreijo7itbs7uwc2ltfeuvcfaublxf6rjo24hf6t4y";

int32 constant CHUNK_MAX_Y = 255;
int32 constant CHUNK_MIN_Y = -63;

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
