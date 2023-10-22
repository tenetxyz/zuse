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
import { PlantDataWithEntity, PokemonDataWithEntity } from "@tenet-derived/src/Types.sol";

contract FarmerFactionSystem is System {
  function reportFarmer(VoxelEntity memory farmerEntity) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    IStore caStore = IStore(BASE_CA_ADDRESS);

    bytes32 farmerCAEntity = CAEntityMapping.get(caStore, WORLD_ADDRESS, farmerEntity.entityId);

    bytes32[][] memory plantEntities = getKeysInTable(caStore, CAEntityReverseMappingTableId);
    bytes32[][] memory farmerLBEntities = getKeysInTable(FarmFactionsLeaderboardTableId);

    for (uint i = 0; i < plantEntities.length; i++) {
      bytes32 plantEntity = plantEntities[i][0];
      if (Plant.getHasValue(caStore, WORLD_ADDRESS, plantEntity)) {
        console.logBytes32(plantEntity);
        VoxelCoord memory entityCoord = getCAEntityPositionStrict(caStore, plantEntity);
        VoxelCoord memory shardCoord = coordToShardCoord(entityCoord);

        PlantConsumer[] memory consumers = abi.decode(
          Plant.getConsumers(caStore, WORLD_ADDRESS, plantEntity),
          (PlantConsumer[])
        );

        for (uint k = 0; k < consumers.length; k++) {
          if (consumers[k].entityId == farmerCAEntity) {
            for (uint j = 0; j < farmerLBEntities.length; j++) {
              if (
                shardCoord.x == int32(int256(uint256(farmerLBEntities[j][0]))) &&
                shardCoord.y == int32(int256(uint256(farmerLBEntities[j][1]))) &&
                shardCoord.z == int32(int256(uint256(farmerLBEntities[j][2])))
              ) {
                bytes32 relevantFarmer = FarmFactionsLeaderboard.getFarmerCAEntity(
                  shardCoord.x,
                  shardCoord.y,
                  shardCoord.z
                );

                if (farmerCAEntity != relevantFarmer) {
                  FarmFactionsLeaderboard.setIsDisqualified(shardCoord.x, shardCoord.y, shardCoord.z, true);
                  return;
                }
                break;
              }
            }
          }
        }
      }
    }
  }

  function claimFarmerFactionsShard(
    VoxelEntity memory farmerEntity,
    VoxelCoord memory coord,
    ObjectType faction
  ) public {
    IStore caStore = IStore(BASE_CA_ADDRESS);
    VoxelCoord memory shardCoord = coordToShardCoord(coord);
    require(
      !hasKey(
        FarmFactionsLeaderboardTableId,
        FarmFactionsLeaderboard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)
      ),
      "FarmerLBSystem: shard already claimed"
    );
    bytes32 farmerCAEntity = CAEntityMapping.get(caStore, WORLD_ADDRESS, farmerEntity.entityId);
    bytes32[][] memory farmerLBEntities = getKeysInTable(FarmFactionsLeaderboardTableId);
    // Initial rank is the number of farmers + 1, ie last place
    FarmFactionsLeaderboard.set(
      shardCoord.x,
      shardCoord.y,
      shardCoord.z,
      farmerLBEntities.length + 1,
      0,
      farmerCAEntity,
      faction,
      false
    );
  }

  function updateFarmerFactionsLeaderboard() public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    IStore caStore = IStore(BASE_CA_ADDRESS);

    // We reset the leaderboard
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
        for (uint j = 0; j < farmerLBEntities.length; j++) {
          if (
            shardCoord.x == int32(int256(uint256(farmerLBEntities[j][0]))) &&
            shardCoord.y == int32(int256(uint256(farmerLBEntities[j][1]))) &&
            shardCoord.z == int32(int256(uint256(farmerLBEntities[j][2])))
          ) {
            totalFarmerScore[j].totalProduced += Plant.getTotalProduced(caStore, WORLD_ADDRESS, plantEntity);
            break;
          }
        }
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
    // but we need to adjust for disqualified farmers
    for (uint i = 0; i < totalFarmerScore.length; i++) {
      if (
        FarmFactionsLeaderboard.getIsDisqualified(
          totalFarmerScore[i].coord.x,
          totalFarmerScore[i].coord.y,
          totalFarmerScore[i].coord.z
        )
      ) {
        rankAdjustment++; // Increase the adjustment factor
        continue; // Skip the rest of the loop iteration
      }

      uint rank = i + 1 - rankAdjustment;
      console.log("set rank");
      FarmFactionsLeaderboard.set(
        totalFarmerScore[i].coord.x,
        totalFarmerScore[i].coord.y,
        totalFarmerScore[i].coord.z,
        rank,
        totalFarmerScore[i].totalProduced,
        FarmFactionsLeaderboard.getFarmerCAEntity(
          totalFarmerScore[i].coord.x,
          totalFarmerScore[i].coord.y,
          totalFarmerScore[i].coord.z
        ),
        FarmFactionsLeaderboard.getFaction(
          totalFarmerScore[i].coord.x,
          totalFarmerScore[i].coord.y,
          totalFarmerScore[i].coord.z
        ),
        false
      );
    }
  }
}
