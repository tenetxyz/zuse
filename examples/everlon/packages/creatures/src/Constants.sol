// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0xB088741f11DB22A5DB2f2ddE851FD1c9DF10FA71;
address constant WORLD_ADDRESS = 0x008154C7A7084Af1A6Ee7252e428f358663d055F;

bytes32 constant FireCreatureObjectID = bytes32(keccak256("creature-fire"));
bytes32 constant WaterCreatureObjectID = bytes32(keccak256("creature-water"));
bytes32 constant GrassCreatureObjectID = bytes32(keccak256("creature-grass"));

bytes32 constant ThermoObjectID = bytes32(keccak256("thermo"));

uint256 constant NUM_BLOCKS_FAINTED = 50;
