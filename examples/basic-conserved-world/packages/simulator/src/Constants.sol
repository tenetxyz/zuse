// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;
string constant SIM_SET_MASS_SIG = "setMass((uint32,bytes32),(int32,int32,int32),uint256,(uint32,bytes32),(int32,int32,int32),uint256)";
string constant SIM_SET_ENERGY_SIG = "setEnergy((uint32,bytes32),(int32,int32,int32),uint256,(uint32,bytes32),(int32,int32,int32),uint256)";
string constant SIM_VELOCITY_CHANGE_SIG = "velocityChange((int32,int32,int32),(int32,int32,int32),(uint32,bytes32),(uint32,bytes32))";
string constant SIM_VELOCITY_CACHE_UPDATE_SIG = "updateVelocityCache((uint32,bytes32))";
string constant SIM_INIT_ENTITY_SIG = "initEntity((uint32,bytes32),uint256,uint256,(int32,int32,int32))";

uint256 constant NUM_BLOCKS_BEFORE_REDUCE_VELOCITY = 60;
