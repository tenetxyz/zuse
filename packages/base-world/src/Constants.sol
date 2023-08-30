// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

string constant BUILD_SIG = "build(bytes32,(int32,int32,int32))";
string constant GIFT_VOXEL_SIG = "giftVoxel(bytes16,bytes32)";
string constant RM_ALL_OWNED_VOXELS_SIG = "removeAllOwnedVoxels()";

uint256 constant NUM_VOXEL_NEIGHBOURS = 10;
uint256 constant MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH = 100;

int32 constant CHUNK_MAX_Y = 255;
int32 constant CHUNK_MIN_Y = -63;
