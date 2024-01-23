// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;
address constant WORLD_ADDRESS = 0x0fe4223AD99dF788A6Dcad148eB4086E6389cEB6;

bytes32 constant FireCreatureObjectID = bytes32(keccak256("creature-fire"));
bytes32 constant WaterCreatureObjectID = bytes32(keccak256("creature-water"));
bytes32 constant GrassCreatureObjectID = bytes32(keccak256("creature-grass"));

bytes32 constant ThermoObjectID = bytes32(keccak256("thermo"));

uint256 constant NUM_BLOCKS_FAINTED = 50;
