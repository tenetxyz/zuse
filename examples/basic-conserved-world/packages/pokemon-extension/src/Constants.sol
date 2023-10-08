// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;
address constant CA_ADDRESS = 0x8464135c8F25Da09e49BC8782676a84730C318bC;

bytes32 constant SoilVoxelID = bytes32(keccak256("soil"));
bytes32 constant PlantVoxelID = bytes32(keccak256("plant"));
bytes32 constant FirePokemonVoxelID = bytes32(keccak256("pokemon-fire"));
bytes32 constant WaterPokemonVoxelID = bytes32(keccak256("pokemon-water"));
bytes32 constant GrassPokemonVoxelID = bytes32(keccak256("pokemon-grass"));

uint256 constant NUM_BLOCKS_FAINTED = 50;
