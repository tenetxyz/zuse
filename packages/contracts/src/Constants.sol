// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
address constant BASE_CA_ADDRESS = 0xa82fF9aFd8f496c3d6ac40E2a0F282E47488CFc9;

string constant REGISTER_EXTENSION_SIG = "registerExtension(bytes4,string)";
string constant CLEAR_COORD_SIG = "clearCoord((int32,int32,int32))";
string constant BUILD_SIG = "build(bytes32,(int32,int32,int32))";
string constant GIFT_VOXEL_SIG = "giftVoxel(bytes16,bytes32)";
string constant RM_ALL_OWNED_VOXELS_SIG = "removeAllOwnedVoxels()";

// A block has six neighbours
uint256 constant NUM_VOXEL_NEIGHBOURS = 6;
uint256 constant MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH = 100;

int32 constant CHUNK_MAX_Y = 255;
int32 constant CHUNK_MIN_Y = -63;
