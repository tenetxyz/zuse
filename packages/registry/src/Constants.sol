// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

string constant REGISTER_VOXEL_TYPE_SIG = "registerVoxelType(string,bytes32,bytes32,bytes32[],bytes32[],bytes32)";
string constant REGISTER_VOXEL_VARIANT_SIG = "registerVoxelVariant(bytes32,(uint256,uint32,bool,bool,bool,uint8,bytes,string))";
string constant REGISTER_CA_SIG = "registerCA(string,string,bytes32[])";
string constant ADD_VOXEL_CA_SIG = "addVoxelToCA(bytes32)";
string constant REGISTER_WORLD_SIG = "registerWorld(string,string,address[])";
string constant WORLD_NOTIFY_NEW_CA_VOXEL_TYPE_SIG = "onNewCAVoxelType(address,bytes32)";
