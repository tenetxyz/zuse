// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

string constant CA_ENTER_WORLD_SIG = "enterWorld(bytes32,bytes4,(int32,int32,int32),bytes32,bytes32[],bytes32[],bytes32)";
string constant CA_EXIT_WORLD_SIG = "exitWorld(bytes32,(int32,int32,int32),bytes32,bytes32[],bytes32[],bytes32)";
string constant CA_MOVE_WORLD_SIG = "moveWorld(bytes32,(int32,int32,int32),(int32,int32,int32),bytes32,bytes32[],bytes32[],bytes32)";
string constant CA_GET_TERRAIN_VOXEL_ID_SIG = "getTerrainVoxelId((int32,int32,int32))";
string constant CA_RUN_INTERACTION_SIG = "runInteraction(bytes4,bytes32,bytes32[],bytes32[],bytes32)";
string constant CA_GET_MIND_SELECTOR_SIG = "getMindSelector(bytes32)";
string constant CA_SET_MIND_SELECTOR_SIG = "setMindSelector(bytes32,bytes4)";
string constant CA_ACTIVATE_VOXEL_SIG = "activateVoxel(bytes32)";
string constant CA_REGISTER_VOXEL_SIG = "registerVoxelType(bytes32)";
