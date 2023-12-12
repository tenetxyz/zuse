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
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";

import { WORLD_ADDRESS } from "@tenet-derived/src/Constants.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { SHARD_DIM } from "@tenet-world/src/Constants.sol";

import { Creature, CreatureData } from "@tenet-creatures/src/codegen/tables/Creature.sol";
import { Plant, PlantData } from "@tenet-farming/src/codegen/tables/Plant.sol";
import { Farmer } from "@tenet-farming/src/codegen/tables/Farmer.sol";
import { PlantConsumer } from "@tenet-farming/src/Types.sol";

import { CreatureDataWithEntity } from "@tenet-derived/src/Types.sol";

contract CreatureFactionSystem is System {
  function reportCreature(bytes32 creatureObjectEntityId) public {
    IStore worldStore = IStore(WORLD_ADDRESS);

    CreatureData memory creatureData = Creature.get(worldStore, WORLD_ADDRESS, creatureObjectEntityId);
    ElementType creatureFaction = creatureData.elementType;

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
          if (consumers[k].objectEntityId == creatureObjectEntityId) {
            for (uint j = 0; j < farmerLBEntities.length; j++) {
              if (
                shardCoord.x == int32(int256(uint256(farmerLBEntities[j][0]))) &&
                shardCoord.y == int32(int256(uint256(farmerLBEntities[j][1]))) &&
                shardCoord.z == int32(int256(uint256(farmerLBEntities[j][2])))
              ) {
                ElementType relevantFarmFaction = FarmFactionsLeaderboard.getFaction(
                  shardCoord.x,
                  shardCoord.y,
                  shardCoord.z
                );

                if (creatureFaction != relevantFarmFaction) {
                  CreatureFactionsLeaderboard.setIsDisqualified(creatureObjectEntityId, true);
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

  function updateCreatureFactionsLeaderboard() public {
    IStore worldStore = IStore(WORLD_ADDRESS);

    // We don't reset the leaderboard here because we need to know if a creature was disqualified, and that info
    // would go away if we reset the leaderboard

    // Get all creature entities
    // TODO: Find a way to do this where we don't have to iterate over all entities
    bytes32[][] memory creatureEntities = getKeysInTable(worldStore, ObjectEntityTableId);
    uint256 numCreatures = 0;
    for (uint i = 0; i < creatureEntities.length; i++) {
      bytes32 creatureObjectEntityId = ObjectEntity.get(worldStore, creatureEntities[i][0]);
      if (Creature.getHasValue(worldStore, WORLD_ADDRESS, creatureObjectEntityId)) {
        numCreatures++;
      }
    }
    CreatureDataWithEntity[] memory creatureDataArray = new CreatureDataWithEntity[](numCreatures);
    uint256 creatureIdx = 0;

    for (uint i = 0; i < creatureEntities.length; i++) {
      bytes32 creatureObjectEntityId = ObjectEntity.get(worldStore, creatureEntities[i][0]);
      if (Creature.getHasValue(worldStore, WORLD_ADDRESS, creatureObjectEntityId)) {
        creatureDataArray[creatureIdx] = CreatureDataWithEntity({
          creatureData: Creature.get(worldStore, WORLD_ADDRESS, creatureObjectEntityId),
          objectEntityId: creatureObjectEntityId
        });
        creatureIdx++;
      }
    }

    bool swapped = false;
    // Sort the creature data array based on numWins
    // TODO: Fix sort algorithm, it's not working
    for (uint i = 0; i < creatureDataArray.length; i++) {
      swapped = false;
      for (uint j = i + 1; j < creatureDataArray.length; j++) {
        if (creatureDataArray[i].creatureData.numWins < creatureDataArray[j].creatureData.numWins) {
          // Swap
          CreatureDataWithEntity memory temp = creatureDataArray[i];
          creatureDataArray[i] = creatureDataArray[j];
          creatureDataArray[j] = temp;
          swapped = true;
        }
      }
      if (!swapped) {
        break;
      }
    }

    uint rankAdjustment = 0;

    for (uint i = 0; i < creatureDataArray.length; i++) {
      if (CreatureFactionsLeaderboard.getIsDisqualified(creatureDataArray[i].objectEntityId)) {
        rankAdjustment++;
        continue;
      }

      uint rank = i + 1 - rankAdjustment; // Adjust the rank
      CreatureFactionsLeaderboard.set(
        creatureDataArray[i].objectEntityId,
        CreatureFactionsLeaderboardData({ rank: rank, isDisqualified: false })
      );
    }

    cleanCreatureFactionsLeaderboard(creatureDataArray);
  }

  function cleanCreatureFactionsLeaderboard(CreatureDataWithEntity[] memory creatureDataArray) internal {
    // remove any entities in the table not present in the creatureDataArray
    bytes32[][] memory creatureLBEntities = getKeysInTable(CreatureFactionsLeaderboardTableId);
    for (uint i = 0; i < creatureLBEntities.length; i++) {
      bool found = false;
      for (uint j = 0; j < creatureDataArray.length; j++) {
        if (creatureLBEntities[i][0] == creatureDataArray[j].objectEntityId) {
          found = true;
          break;
        }
      }
      if (!found) {
        CreatureFactionsLeaderboard.deleteRecord(creatureLBEntities[i][0]);
      }
    }
  }
}
