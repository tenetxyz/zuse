// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;

string constant CA_ENTER_WORLD_SIG = "enterWorld(bytes32,(int32,int32,int32),bytes32)";
string constant CA_EXIT_WORLD_SIG = "exitWorld(bytes32,(int32,int32,int32),bytes32)";
string constant CA_RUN_INTERACTION_SIG = "runInteraction(bytes32,bytes32[],bytes32[],bytes32)";

bytes32 constant EMPTY_ID = bytes32(0x0);

bytes32 constant AirVoxelID = bytes32(keccak256("air"));
bytes32 constant AirVoxelVariantID = bytes32(keccak256("air"));

bytes32 constant DirtVoxelID = bytes32(keccak256("dirt"));
bytes32 constant DirtVoxelVariantID = bytes32(keccak256("dirt"));
string constant DirtTexture = "bafkreihy3pblhqaqquwttcykwlyey3umpou57rkvtncpdrjo7mlgna53g4";
string constant DirtUVWrap = "bafkreifsrs64rckwnfkwcyqkzpdo3tpa2at7jhe6bw7jhevkxa7estkdnm";

bytes32 constant GrassVoxelID = bytes32(keccak256("grass"));
bytes32 constant GrassVoxelVariantID = bytes32(keccak256("grass"));
string constant GrassTexture = "bafkreidtk7vevmnzt6is5dreyoocjkyy56bk66zbm5bx6wzck73iogdl6e";
string constant GrassSideTexture = "bafkreien7wqwfkckd56rehamo2riwwy5jvecm5he6dmbw2lucvh3n4w6ue";
string constant GrassUVWrap = "bafkreiaur4pmmnh3dts6rjtfl5f2z6ykazyuu4e2cbno6drslfelkga3yy";

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
