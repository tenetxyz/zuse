// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

bytes16 constant TENET_NAMESPACE = bytes16("tenet");

string constant REGISTER_VOXEL_VARIANT_SIG = "tenet_VoxelRegistrySys_registerVoxelVariant(bytes32,(uint256,uint32,bool,bool,bool,uint8,bytes,string))";
string constant REGISTER_VOXEL_TYPE_SIG = "tenet_VoxelRegistrySys_registerVoxelType(string,bytes32,string,bytes4)";

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
