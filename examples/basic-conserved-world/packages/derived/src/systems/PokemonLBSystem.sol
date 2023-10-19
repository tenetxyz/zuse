// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, BodySimData } from "@tenet-utils/src/Types.sol";
import { Position, PositionData } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeTableId } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { WORLD_ADDRESS, BASE_CA_ADDRESS } from "@tenet-derived/src/Constants.sol";
import { getEntitySimData } from "@tenet-world/src/CallUtils.sol";
import { getEntityAtCoord, getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";
import { getNeighbourEntities } from "@tenet-simulator/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { Pokemon, PokemonData, PokemonTableId } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { Plant, PlantData, PlantStage } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { PokemonLeaderboard, PokemonLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";

contract PokemonLBSystem is System {
  function updatePokemonLeaderboard() public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    IStore caStore = IStore(BASE_CA_ADDRESS);

    // We reset the leaderboard, so if a pokemon was mined, it will be removed from the leaderboard
    resetLeaderboard();

    // Get all pokemon entities
    bytes32[][] memory pokemonEntities = getKeysInTable(caStore, PokemonTableId);
    PokemonData[] memory pokemonDataArray = new PokemonData[](pokemonEntities.length);

    for (uint i = 0; i < pokemonEntities.length; i++) {
      bytes32 pokemonEntity = pokemonEntities[i][0];
      pokemonDataArray[i] = Pokemon.get(caStore, WORLD_ADDRESS, pokemonEntity);
    }

    bool swapped = false;
    // Sort the pokemon data array based on numWins
    for (uint i = 0; i < pokemonDataArray.length; i++) {
      swapped = false;
      for (uint j = i + 1; j < pokemonDataArray.length; j++) {
        if (pokemonDataArray[i].numWins < pokemonDataArray[j].numWins) {
          // Swap
          PokemonData memory temp = pokemonDataArray[i];
          pokemonDataArray[i] = pokemonDataArray[j];
          pokemonDataArray[j] = temp;
          swapped = true;
        }
      }
      if (!swapped) {
        break;
      }
    }

    // Now, the rank of the pokemonEntity is just its index + 1 in the sorted array
    for (uint i = 0; i < pokemonDataArray.length; i++) {
      uint rank = i + 1;
      PokemonLeaderboard.set(pokemonEntities[i][0], rank);
    }
  }

  function resetLeaderboard() internal {
    bytes32[][] memory pokemonLBEntities = getKeysInTable(PokemonLeaderboardTableId);
    for (uint i = 0; i < pokemonLBEntities.length; i++) {
      PokemonLeaderboard.deleteRecord(pokemonLBEntities[i][0]);
    }
  }
}
