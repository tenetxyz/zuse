// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

string constant REGISTER_VOXEL_TYPE_SIG = "registerVoxelType(string,bytes32,bytes32,bytes32[],bytes32[],bytes32,(bytes4,bytes4,bytes4,bytes4,bytes4,(bytes4,string,string)[]),bytes)";
string constant REGISTER_VOXEL_VARIANT_SIG = "registerVoxelVariant(bytes32,(uint256,uint32,bool,bool,bool,uint8,bytes,string))";
string constant REGISTER_CA_SIG = "registerCA(string,string,bytes32[])";
string constant ADD_VOXEL_CA_SIG = "addVoxelToCA(bytes32)";
string constant REGISTER_WORLD_SIG = "registerWorld(string,string,address[])";
string constant WORLD_NOTIFY_NEW_CA_VOXEL_TYPE_SIG = "onNewCAVoxelType(address,bytes32)";
string constant REGISTER_CREATION_SIG = "registerCreation(string,string,(bytes32,bytes32)[],(int32,int32,int32)[],(bytes32,(int32,int32,int32),(int32,int32,int32)[])[])";
string constant GET_VOXELS_IN_CREATION_SIG = "getVoxelsInCreation(bytes32)";
string constant CREATION_SPAWNED_SIG = "creationSpawned(bytes32)";
string constant VOXEL_SPAWNED_SIG = "voxelSpawned(bytes32)";
string constant REGISTER_DECISION_RULE_SIG = "registerDecisionRule(string,string,bytes32,bytes32,bytes4)";
string constant REGISTER_DECISION_RULE_WORLD_SIG = "registerDecisionRuleForWorld(string,string,bytes32,bytes32,address,bytes4)";
string constant REGISTER_MIND_SIG = "registerMind(bytes32,(address,string,string,(bytes32,bytes32,address,bytes32)[]))";
string constant REGISTER_MIND_WORLD_SIG = "registerMindForWorld(bytes32,address,(address,string,string,bytes4))";
