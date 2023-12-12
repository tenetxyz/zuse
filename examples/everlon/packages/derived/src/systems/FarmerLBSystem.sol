// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

import { FarmLeaderboard, FarmLeaderboardData, FarmLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";

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
import { Farmer } from "@tenet-farming/src/codegen/tables/Farmer.sol";

import { PlantDataWithEntity } from "@tenet-derived/src/Types.sol";

contract FarmerLBSystem is System {
  function claimFarmerShard(bytes32 farmerObjectEntityId) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    require(
      hasKey(worldStore, OwnedByTableId, OwnedBy.encodeKeyTuple(farmerObjectEntityId)) &&
        OwnedBy.get(worldStore, farmerObjectEntityId) == _msgSender(),
      "FarmerLBSystem: You do not own this entity"
    );
    VoxelCoord memory coord = getVoxelCoord(worldStore, farmerObjectEntityId);
    VoxelCoord memory shardCoord = coordToShardCoord(coord, SHARD_DIM);
    require(
      !hasKey(FarmLeaderboardTableId, FarmLeaderboard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)),
      "FarmerLBSystem: Shard already claimed"
    );
    bytes32[][] memory farmerLBEntities = getKeysInTable(FarmLeaderboardTableId);
    // Initial rank is the number of farmers + 1, ie last place
    FarmLeaderboard.set(
      shardCoord.x,
      shardCoord.y,
      shardCoord.z,
      FarmLeaderboardData({
        rank: farmerLBEntities.length + 1,
        totalProduction: 0,
        farmerObjectEntityId: farmerObjectEntityId
      })
    );
  }

  function updateFarmerLeaderboard() public {
    IStore worldStore = IStore(WORLD_ADDRESS);

    // We reset the leaderboard
    bytes32[][] memory farmerLBEntities = getKeysInTable(FarmLeaderboardTableId);
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

    // Get all plant entities
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

    // Now, the rank of the shard coord is just its index + 1 in the sorted array
    for (uint i = 0; i < totalFarmerScore.length; i++) {
      uint rank = i + 1;
      FarmLeaderboard.set(
        totalFarmerScore[i].coord.x,
        totalFarmerScore[i].coord.y,
        totalFarmerScore[i].coord.z,
        FarmLeaderboardData({
          rank: rank,
          totalProduction: totalFarmerScore[i].totalProduced,
          farmerObjectEntityId: FarmLeaderboard.getFarmerObjectEntityId(
            totalFarmerScore[i].coord.x,
            totalFarmerScore[i].coord.y,
            totalFarmerScore[i].coord.z
          )
        })
      );
    }
  }
}
