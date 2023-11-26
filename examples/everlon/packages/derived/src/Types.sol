// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { PokemonData } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

struct PlantDataWithEntity {
  VoxelCoord coord;
  uint256 totalProduced;
}

struct PokemonDataWithEntity {
  PokemonData pokemonData;
  bytes32 entity;
}
