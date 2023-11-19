// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

string constant REGISTER_OBJECT_TYPE_SIG = "registerObjectType(bytes32,address,bytes4,bytes4,bytes4,bytes4,string,string)";
string constant REGISTER_CREATION_SIG = "registerCreation(string,string,(bytes32,bytes32)[],(int32,int32,int32)[],(bytes32,(int32,int32,int32),(int32,int32,int32)[])[])";
string constant GET_VOXELS_IN_CREATION_SIG = "getVoxelsInCreation(bytes32)";
string constant CREATION_SPAWNED_SIG = "creationSpawned(bytes32)";
string constant VOXEL_SPAWNED_SIG = "voxelSpawned(bytes32)";
string constant REGISTER_DECISION_RULE_SIG = "registerDecisionRule(string,string,bytes32,bytes32,bytes4)";
string constant REGISTER_DECISION_RULE_WORLD_SIG = "registerDecisionRuleForWorld(string,string,bytes32,bytes32,address,bytes4)";
string constant REGISTER_MIND_SIG = "registerMind(bytes32,string,string,bytes4)";
string constant REGISTER_MIND_WORLD_SIG = "registerMindForWorld(bytes32,address,string,string,bytes4)";
