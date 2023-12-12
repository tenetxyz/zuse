// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { VoxelCoord, ObjectProperties, ElementType } from "@tenet-utils/src/Types.sol";

import { CreatureFactionsLeaderboard, CreatureFactionsLeaderboardData, CreatureFactionsLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { FarmFactionsLeaderboard, FarmFactionsLeaderboardData, FarmFactionsLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";

import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { ObjectEntity, ObjectEntityTableId } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";

import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord } from "@tenet-base-world/src/Utils.sol";

import { WORLD_ADDRESS } from "@tenet-derived/src/Constants.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { SHARD_DIM } from "@tenet-world/src/Constants.sol";

import { Creature, CreatureData } from "@tenet-creatures/src/codegen/tables/Creature.sol";
import { Plant, PlantData } from "@tenet-farming/src/codegen/tables/Plant.sol";
import { PlantConsumer } from "@tenet-farming/src/Types.sol";
import { Farmer } from "@tenet-farming/src/codegen/tables/Farmer.sol";

import { PlantDataWithEntity } from "@tenet-derived/src/Types.sol";

contract FarmerFactionSystem is System {
  function reportFarmer(bytes32 farmerObjectEntityId) public {
    IStore worldStore = IStore(WORLD_ADDRESS);

    // TODO: Find a way to do this where we don't have to iterate over all entities
    bytes32[][] memory plantEntities = getKeysInTable(worldStore, ObjectEntityTableId);
    bytes32[][] memory farmerLBEntities = getKeysInTable(FarmFactionsLeaderboardTableId);

    for (uint i = 0; i < plantEntities.length; i++) {
      bytes32 plantObjectEntityId = ObjectEntity.get(worldStore, plantEntities[i][0]);
      if (Plant.getHasValue(worldStore, WORLD_ADDRESS, plantObjectEntityId)) {
        VoxelCoord memory entityCoord = positionDataToVoxelCoord(Position.get(worldStore, plantEntities[i][0]));
        VoxelCoord memory shardCoord = coordToShardCoord(entityCoord, SHARD_DIM);

        PlantConsumer[] memory consumers = abi.decode(
          Plant.getConsumers(worldStore, WORLD_ADDRESS, plantObjectEntityId),
          (PlantConsumer[])
        );

        for (uint k = 0; k < consumers.length; k++) {
          if (consumers[k].objectEntityId == farmerObjectEntityId) {
            for (uint j = 0; j < farmerLBEntities.length; j++) {
              if (
                shardCoord.x == int32(int256(uint256(farmerLBEntities[j][0]))) &&
                shardCoord.y == int32(int256(uint256(farmerLBEntities[j][1]))) &&
                shardCoord.z == int32(int256(uint256(farmerLBEntities[j][2])))
              ) {
                bytes32 relevantFarmerObjectEntityId = FarmFactionsLeaderboard.getFarmerObjectEntityId(
                  shardCoord.x,
                  shardCoord.y,
                  shardCoord.z
                );

                if (farmerObjectEntityId != relevantFarmerObjectEntityId) {
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

  function claimFarmerFactionsShard(bytes32 farmerObjectEntityId, ElementType faction) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    require(
      hasKey(worldStore, OwnedByTableId, OwnedBy.encodeKeyTuple(farmerObjectEntityId)) &&
        OwnedBy.get(worldStore, farmerObjectEntityId) == _msgSender(),
      "FarmerFactionSystem: You do not own this entity"
    );
    VoxelCoord memory coord = getVoxelCoord(worldStore, farmerObjectEntityId);
    VoxelCoord memory shardCoord = coordToShardCoord(coord, SHARD_DIM);
    require(
      !hasKey(
        FarmFactionsLeaderboardTableId,
        FarmFactionsLeaderboard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)
      ),
      "FarmerFactionSystem: Shard already claimed"
    );
    bytes32[][] memory farmerLBEntities = getKeysInTable(FarmFactionsLeaderboardTableId);
    // Initial rank is the number of farmers + 1, ie last place
    FarmFactionsLeaderboard.set(
      shardCoord.x,
      shardCoord.y,
      shardCoord.z,
      FarmFactionsLeaderboardData({
        rank: farmerLBEntities.length + 1,
        totalProduction: 0,
        farmerObjectEntityId: farmerObjectEntityId,
        faction: faction,
        isDisqualified: false
      })
    );
  }

  function updateFarmerFactionsLeaderboard() public {
    IStore worldStore = IStore(WORLD_ADDRESS);

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

    // TODO: Find a way to do this where we don't have to iterate over all entities
    bytes32[][] memory plantEntities = getKeysInTable(worldStore, ObjectEntityTableId);

    for (uint i = 0; i < plantEntities.length; i++) {
      bytes32 plantObjectEntityId = ObjectEntity.get(worldStore, plantEntities[i][0]);
      if (Plant.getHasValue(worldStore, WORLD_ADDRESS, plantObjectEntityId)) {
        VoxelCoord memory entityCoord = positionDataToVoxelCoord(Position.get(worldStore, plantEntities[i][0]));
        VoxelCoord memory shardCoord = coordToShardCoord(entityCoord, SHARD_DIM);
        // figure out the index of this shardCoord in farmerLBEntities
        for (uint j = 0; j < farmerLBEntities.length; j++) {
          if (
            shardCoord.x == int32(int256(uint256(farmerLBEntities[j][0]))) &&
            shardCoord.y == int32(int256(uint256(farmerLBEntities[j][1]))) &&
            shardCoord.z == int32(int256(uint256(farmerLBEntities[j][2])))
          ) {
            totalFarmerScore[j].totalProduced += Plant.getTotalProduced(worldStore, WORLD_ADDRESS, plantObjectEntityId);
            break;
          }
        }
      }
    }

    bool swapped = false;
    // TODO: Fix sort algorithm, it's not working
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
      FarmFactionsLeaderboard.set(
        totalFarmerScore[i].coord.x,
        totalFarmerScore[i].coord.y,
        totalFarmerScore[i].coord.z,
        FarmFactionsLeaderboardData({
          rank: rank,
          totalProduction: totalFarmerScore[i].totalProduced,
          farmerObjectEntityId: FarmFactionsLeaderboard.getFarmerObjectEntityId(
            totalFarmerScore[i].coord.x,
            totalFarmerScore[i].coord.y,
            totalFarmerScore[i].coord.z
          ),
          faction: FarmFactionsLeaderboard.getFaction(
            totalFarmerScore[i].coord.x,
            totalFarmerScore[i].coord.y,
            totalFarmerScore[i].coord.z
          ),
          isDisqualified: false
        })
      );
    }
  }
}
