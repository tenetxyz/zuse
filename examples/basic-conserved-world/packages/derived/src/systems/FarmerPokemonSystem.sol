// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { CAEntityReverseMapping, CAEntityReverseMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, BodySimData, ObjectType } from "@tenet-utils/src/Types.sol";
import { Position, PositionData } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeTableId } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { WORLD_ADDRESS, BASE_CA_ADDRESS } from "@tenet-derived/src/Constants.sol";
import { getEntitySimData } from "@tenet-world/src/CallUtils.sol";
import { getEntityAtCoord, getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";
import { getNeighbourEntities } from "@tenet-simulator/src/Utils.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { console } from "forge-std/console.sol";
import { Pokemon, PokemonData, PokemonTableId } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { Plant, PlantData, PlantStage } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { FarmFactionsLeaderboard, FarmFactionsLeaderboardTableId, PokemonFactionsLeaderboard, PokemonFactionsLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { PlantConsumer } from "@tenet-pokemon-extension/src/Types.sol";


struct PlantDataWithEntity {
  VoxelCoord coord;
  uint256 totalProduced;
}

struct PokemonDataWithEntity {
  PokemonData pokemonData;
  bytes32 entity;
}

contract FarmerPokemonSystem is System {

  function reportPokemon(address memory pokemonEntity) public {
    PokemonData pokemonData = Pokemon.get(caStore, WORLD_ADDRESS, pokemonEntity);
    ObjectType pokemonFaction = pokemonData.pokemonType;

    bytes32[][] memory plantEntities = getKeysInTable(caStore, CAEntityReverseMappingTableId);
    bytes32[][] memory farmerLBEntities = getKeysInTable(FarmFactionsLeaderboardTableId);

    bool memory didCheat = false;

    for (uint i = 0; i < plantEntities.length; i++) {
      bytes32 plantEntity = plantEntities[i][0];
      if (Plant.getHasValue(caStore, WORLD_ADDRESS, plantEntity)) {
        console.logBytes32(plantEntity);
        VoxelCoord memory entityCoord = getCAEntityPositionStrict(caStore, plantEntity);
        VoxelCoord memory shardCoord = coordToShardCoord(entityCoord);

        PlantConsumer[] memory consumers = Plant.getConsumers(caStore, WORLD_ADDRESS, plantEntity);

        for (uint k = 0; k < consumers.length; k++) {    
          if  (consumers[k].entityId == pokemonEntity) { 
            for (uint j = 0; j < farmerLBEntities.length; j++) {
              if (
                shardCoord.x == int32(int256(uint256(farmerLBEntities[j][0]))) &&
                shardCoord.y == int32(int256(uint256(farmerLBEntities[j][1]))) &&
                shardCoord.z == int32(int256(uint256(farmerLBEntities[j][2])))
              ) {
                ObjectType relevantFarmFaction = FarmFactionsLeaderboard.getFaction(shardCoord.x, shardCoord.y, shardCoord.z);

                if (pokemonFaction != relevantFarmFaction) {
                  didCheat = true;
                }
                break;
              }
            } 
          }
        }
      }
    }

    if (didCheat == true) {
      PokemonFactionsLeaderboard.set(pokemonEntity, 0, true);
    }
  }

  function reportFarmer(address memory farmerEntity) public {

    bytes32[][] memory plantEntities = getKeysInTable(caStore, CAEntityReverseMappingTableId);
    bytes32[][] memory farmerLBEntities = getKeysInTable(FarmFactionsLeaderboardTableId);

    bool memory didCheat = false;

    for (uint i = 0; i < plantEntities.length; i++) {
      bytes32 plantEntity = plantEntities[i][0];
      if (Plant.getHasValue(caStore, WORLD_ADDRESS, plantEntity)) {
        console.logBytes32(plantEntity);
        VoxelCoord memory entityCoord = getCAEntityPositionStrict(caStore, plantEntity);
        VoxelCoord memory shardCoord = coordToShardCoord(entityCoord);

        PlantConsumer[] memory consumers = Plant.getConsumers(caStore, WORLD_ADDRESS, plantEntity);

        for (uint k = 0; k < consumers.length; k++) {    
          if  (consumers[k].entityId == farmerEntity) { 
            for (uint j = 0; j < farmerLBEntities.length; j++) {
              if (
                shardCoord.x == int32(int256(uint256(farmerLBEntities[j][0]))) &&
                shardCoord.y == int32(int256(uint256(farmerLBEntities[j][1]))) &&
                shardCoord.z == int32(int256(uint256(farmerLBEntities[j][2])))
              ) {
                address relevantFarmer = FarmFactionsLeaderboard.getFarmer(shardCoord.x, shardCoord.y, shardCoord.z);

                if (farmerEntity != relevantFarmer) {
                  didCheat = true;
                }
                break;
              }
            } 
          }
        }
      }
    }

    if (didCheat == true) {
      FarmFactionsLeaderboard.set(
        shardCoord.x, shardCoord.y, shardCoord.z, 
        0, 
        FarmFactionsLeaderboard.getTotalProduction(tshardCoord.x, shardCoord.y, shardCoord.z), 
        farmerEntity, 
        FarmFactionsLeaderboard.getFaction(tshardCoord.x, shardCoord.y, shardCoord.z), 
        true
        );
    }
  };

  function claimShard(VoxelCoord memory coord, ObjectType memory faction) public {
    VoxelCoord memory shardCoord = coordToShardCoord(coord);
    require(
      !hasKey(FarmFactionsLeaderboardTableId, FarmFactionsLeaderboard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)),
      "FarmerLBSystem: shard already claimed"
    );
    address farmer = _msgSender();
    bytes32[][] memory farmerLBEntities = getKeysInTable(FarmFactionsLeaderboardTableId);
    FarmFactionsLeaderboard.set(shardCoord.x, shardCoord.y, shardCoord.z, farmerLBEntities.length + 1, 0, farmer, faction, false);
  }

  function updateFarmerLeaderboard() public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    IStore caStore = IStore(BASE_CA_ADDRESS);

    // We reset the leaderboard, so if a pokemon was mined, it will be removed from the leaderboard
    bytes32[][] memory farmerLBEntities = getKeysInTable(FarmFactionsLeaderboardTableId);
    PlantDataWithEntity[] memory totalFarmerScore = new PlantDataWithEntity[](farmerLBEntities.length);
    // init shard coords
    for (uint i = 0; i < farmerLBEntities.length; i++) {
      totalFarmerScore[i] = PlantDataWithEntity({
        coord: VoxelCoord({
          x: int32(int256(uint256(farmerLBEntities[i][0]))),
          y: int32(int256(uint256(farmerLBEntities[i][1]))),
          z: int32(int256(uint256(farmerLBEntities[i][2])))
        }),
        totalProduced: 0
      });
    }

    bytes32[][] memory plantEntities = getKeysInTable(caStore, CAEntityReverseMappingTableId);

    for (uint i = 0; i < plantEntities.length; i++) {
      bytes32 plantEntity = plantEntities[i][0];
      if (Plant.getHasValue(caStore, WORLD_ADDRESS, plantEntity)) {
        console.logBytes32(plantEntity);
        VoxelCoord memory entityCoord = getCAEntityPositionStrict(caStore, plantEntity);
        VoxelCoord memory shardCoord = coordToShardCoord(entityCoord);
        // figure out the index of this shardCoord in farmerLBEntities
        uint256 farmerLBIdx = 0;
        for (uint j = 0; j < farmerLBEntities.length; j++) {
          if (
            shardCoord.x == int32(int256(uint256(farmerLBEntities[j][0]))) &&
            shardCoord.y == int32(int256(uint256(farmerLBEntities[j][1]))) &&
            shardCoord.z == int32(int256(uint256(farmerLBEntities[j][2])))
          ) {
            farmerLBIdx = j;
            break;
          }
        }
        totalFarmerScore[farmerLBIdx].totalProduced += Plant.getTotalProduced(caStore, WORLD_ADDRESS, plantEntity);
      }
    }

    bool swapped = false;
    // Sort the totalFarmerScore data array based on numWins
    for (uint i = 0; i < totalFarmerScore.length; i++) {
      swapped = false;
      for (uint j = i + 1; j < totalFarmerScore.length; j++) {
        if (totalFarmerScore[i].totalProduced < totalFarmerScore[j].totalProduced) {
          // Swap
          PlantDataWithEntity memory temp = totalFarmerScore[i];
          totalFarmerScore[i] = totalFarmerScore[j];
          totalFarmerScore[j] = temp;
          swapped = true;
        }
      }
      if (!swapped) {
        break;
      }
    }


    uint rankAdjustment = 0;

    // Now, the rank of the shard coord is just its index + 1 in the sorted array
    for (uint i = 0; i < totalFarmerScore.length; i++) {
        if (FarmFactionsLeaderboard.getIsDisqualified(totalFarmerScore[i].coord.x, totalFarmerScore[i].coord.y, totalFarmerScore[i].coord.z)) {
          rankAdjustment++;  // Increase the adjustment factor
          continue;  // Skip the rest of the loop iteration
        }

      uint rank = i + 1 - rankAdjustment;
      console.log("set rank");
      FarmFactionsLeaderboard.set(
        totalFarmerScore[i].coord.x,
        totalFarmerScore[i].coord.y,
        totalFarmerScore[i].coord.z,
        rank,
        totalFarmerScore[i].totalProduced,
        FarmFactionsLeaderboard.getFarmer(totalFarmerScore[i].coord.x, totalFarmerScore[i].coord.y, totalFarmerScore[i].coord.z),
        FarmFactionsLeaderboard.getFaction(totalFarmerScore[i].coord.x, totalFarmerScore[i].coord.y, totalFarmerScore[i].coord.z),
        false,
      );
    }
  }

  function updatePokemonLeaderboard() public {
      IStore worldStore = IStore(WORLD_ADDRESS);
      IStore caStore = IStore(BASE_CA_ADDRESS);

      // We reset the leaderboard, so if a pokemon was mined, it will be removed from the leaderboard
      resetLeaderboard();

      // Get all pokemon entities
      bytes32[][] memory pokemonEntities = getKeysInTable(caStore, CAEntityReverseMappingTableId);
      uint256 numPokemon = 0;
      for (uint i = 0; i < pokemonEntities.length; i++) {
        if (Pokemon.getHasValue(caStore, WORLD_ADDRESS, pokemonEntities[i][0])) {
          numPokemon++;
        }
      }
      PokemonDataWithEntity[] memory pokemonDataArray = new PokemonDataWithEntity[](numPokemon);
      console.log("pokemonEntities");
      console.logUint(numPokemon);
      uint256 pokemonIdx = 0;

      for (uint i = 0; i < pokemonEntities.length; i++) {
        bytes32 pokemonEntity = pokemonEntities[i][0];
        if (Pokemon.getHasValue(caStore, WORLD_ADDRESS, pokemonEntity)) {
          console.logBytes32(pokemonEntity);
          pokemonDataArray[pokemonIdx] = PokemonDataWithEntity({
            pokemonData: Pokemon.get(caStore, WORLD_ADDRESS, pokemonEntity),
            entity: pokemonEntity
          });
          pokemonIdx++;
        }
      }

      bool swapped = false;
      // Sort the pokemon data array based on numWins
      for (uint i = 0; i < pokemonDataArray.length; i++) {
        swapped = false;
        for (uint j = i + 1; j < pokemonDataArray.length; j++) {
          if (pokemonDataArray[i].pokemonData.numWins < pokemonDataArray[j].pokemonData.numWins) {
            // Swap
            PokemonDataWithEntity memory temp = pokemonDataArray[i];
            pokemonDataArray[i] = pokemonDataArray[j];
            pokemonDataArray[j] = temp;
            swapped = true;
          }
        }
        if (!swapped) {
          break;
        }
      }
  
    uint rankAdjustment = 0; 

    for (uint i = 0; i < pokemonDataArray.length; i++) {
      if (PokemonFactionsLeaderboard.getIsDisqualified(pokemonDataArray[i].entity)) {
        rankAdjustment++;
        continue;
      }
      
      uint rank = i + 1 - rankAdjustment; // Adjust the rank
      console.log("set rank");
      PokemonFactionsLeaderboard.set(pokemonDataArray[i].entity, rank, false);
    }
  }

  function resetLeaderboard() internal {
    bytes32[][] memory pokemonLBEntities = getKeysInTable(PokemonFactionsLeaderboardTableId);
    for (uint i = 0; i < pokemonLBEntities.length; i++) {
      PokemonFactionsLeaderboard.deleteRecord(pokemonLBEntities[i][0]);
    }
  }
}
