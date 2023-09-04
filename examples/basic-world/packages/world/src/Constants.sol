// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;
address constant BASE_CA_ADDRESS = 0x8464135c8F25Da09e49BC8782676a84730C318bC;

string constant BUILD_SIG = "build(bytes32,(int32,int32,int32))";
string constant GIFT_VOXEL_SIG = "giftVoxel(bytes16,bytes32)";
string constant RM_ALL_OWNED_VOXELS_SIG = "removeAllOwnedVoxels()";

int32 constant CHUNK_MAX_Y = 255;
int32 constant CHUNK_MIN_Y = -63;
