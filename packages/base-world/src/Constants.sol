// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

string constant WORLD_MOVE_SIG = "move(bytes32,bytes32,(int32,int32,int32),(int32,int32,int32))";
string constant WORLD_GET_OBJECT_PROPERTIES_SIG = "getObjectProperties(bytes32)";

uint256 constant NUM_MAX_INVENTORY_SLOTS = 35;

address constant REGISTRY_ADDRESS = 0xB088741f11DB22A5DB2f2ddE851FD1c9DF10FA71;

// TODO: Move SIMULATOR_ADDRESS to this file
