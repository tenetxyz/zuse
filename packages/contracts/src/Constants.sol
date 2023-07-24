// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

address constant REGISTRY_WORLD = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

bytes16 constant TENET_NAMESPACE = bytes16("tenet");

string constant REGISTER_EXTENSION_SIG = "tenet_ExtensionSystem_registerExtension(bytes4,string)";
string constant CLEAR_COORD_SIG = "tenet_MineSystem_clearCoord((int32,int32,int32))";
string constant BUILD_SIG = "tenet_BuildSystem_build(bytes32,(int32,int32,int32))";
string constant GIFT_VOXEL_SIG = "tenet_GiftVoxelSystem_giftVoxel(bytes16,bytes32)";
string constant RM_ALL_OWNED_VOXELS_SIG = "tenet_RmVoxelSystem_removeAllOwnedVoxels()";

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

// A block has six neighbours
uint256 constant NUM_VOXEL_NEIGHBOURS = 6;
uint256 constant MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH = 100;
