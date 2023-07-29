// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;

string constant CA_ENTER_WORLD_SIG = "enterWorld(bytes32,(int32,int32,int32),bytes32)";
string constant CA_EXIT_WORLD_SIG = "exitWorld(bytes32,(int32,int32,int32),bytes32)";
string constant CA_RUN_INTERACTION_SIG = "runInteraction(bytes32,bytes32[],bytes32[],bytes32)";

bytes32 constant AirVoxelID = bytes32(keccak256("air"));
bytes32 constant AirVoxelVariantID = bytes32(keccak256("air"));

bytes32 constant ElectronVoxelID = bytes32(keccak256("electron"));
bytes32 constant ElectronVoxelVariantID = bytes32(keccak256("electron"));
string constant ElectronTexture = "bafkreibmk2qi52v4atyfka3x5ygj44vfig7ks4jz6xzxqfdzduux3fqifa";
