// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;
address constant CA_ADDRESS = 0x8464135c8F25Da09e49BC8782676a84730C318bC;

bytes32 constant ProteinSoilVoxelID = bytes32(keccak256("soil-protein"));
bytes32 constant ElixirSoilVoxelID = bytes32(keccak256("soil-elixir"));
bytes32 constant ConcentrativeSoilVoxelID = bytes32(keccak256("soil-concentrative"));
bytes32 constant DiffusiveSoilVoxelID = bytes32(keccak256("soil-diffusive"));
bytes32 constant PlantVoxelID = bytes32(keccak256("plant"));
bytes32 constant FirePokemonVoxelID = bytes32(keccak256("pokemon-fire"));
bytes32 constant WaterPokemonVoxelID = bytes32(keccak256("pokemon-water"));
bytes32 constant GrassPokemonVoxelID = bytes32(keccak256("pokemon-grass"));
bytes32 constant FarmerVoxelID = bytes32(keccak256("farmer"));

bytes32 constant PlantSeedVoxelVariantID = bytes32(keccak256("plant-seed"));
bytes32 constant PlantProteinVoxelVariantID = bytes32(keccak256("plant-protein"));
bytes32 constant PlantElixirVoxelVariantID = bytes32(keccak256("plant-elixir"));
bytes32 constant PlantFlowerVoxelVariantID = bytes32(keccak256("plant-flower"));

uint256 constant NUM_BLOCKS_FAINTED = 50;
