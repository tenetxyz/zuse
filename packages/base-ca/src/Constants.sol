// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;

string constant CA_ENTER_WORLD_SIG = "enterWorld(bytes32,bytes4,(int32,int32,int32),bytes32,bytes32[],bytes32[],bytes32)";
string constant CA_EXIT_WORLD_SIG = "exitWorld(bytes32,(int32,int32,int32),bytes32,bytes32[],bytes32[],bytes32)";
string constant CA_MOVE_WORLD_SIG = "moveWorld(bytes32,(int32,int32,int32),(int32,int32,int32),bytes32,bytes32[],bytes32[],bytes32)";
string constant CA_RUN_INTERACTION_SIG = "runInteraction(bytes4,bytes32,bytes32[],bytes32[],bytes32)";
string constant CA_ACTIVATE_BODY_SIG = "activateBody(bytes32)";
string constant CA_REGISTER_BODY_SIG = "registerBodyType(bytes32)";

bytes32 constant AirVoxelID = bytes32(keccak256("air"));
bytes32 constant AirVoxelVariantID = bytes32(keccak256("air"));
bytes32 constant ElectronVoxelID = bytes32(keccak256("electron"));
