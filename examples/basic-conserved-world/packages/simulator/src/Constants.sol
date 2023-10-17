// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;

// Signatures
string constant SIM_INIT_ENTITY_SIG = "initEntity((uint32,bytes32),uint256,uint256,(int32,int32,int32))";
string constant SIM_INIT_AGENT_SIG = "initAgent((uint32,bytes32),uint256,uint256)";
string constant SIM_ON_BUILD_SIG = "onBuild((uint32,bytes32),(uint32,bytes32),(int32,int32,int32),uint256)";
string constant SIM_ON_MINE_SIG = "onMine((uint32,bytes32),(uint32,bytes32),(int32,int32,int32))";
string constant SIM_ON_MOVE_SIG = "onMove((uint32,bytes32),(uint32,bytes32),(int32,int32,int32),(uint32,bytes32),(int32,int32,int32))";
string constant SIM_ON_ACTIVATE_SIG = "onActivate((uint32,bytes32),(uint32,bytes32),(int32,int32,int32))";
string constant SIM_VELOCITY_CACHE_UPDATE_SIG = "updateVelocityCache((uint32,bytes32))";

// Other constants
uint256 constant NUM_BLOCKS_BEFORE_REDUCE_VELOCITY = 60;
