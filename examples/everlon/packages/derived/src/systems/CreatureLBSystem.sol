// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

import { CreatureLeaderboard, CreatureLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";

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

import { CreatureDataWithEntity } from "@tenet-derived/src/Types.sol";

contract CreatureLBSystem is System {
  function updateCreatureLeaderboard() public {
    IStore worldStore = IStore(WORLD_ADDRESS);

    // We reset the leaderboard, so if a creature was mined, it will be removed from the leaderboard
    resetLeaderboard();

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

    // Now, the rank of the creature is just its index + 1 in the sorted array
    for (uint i = 0; i < creatureDataArray.length; i++) {
      uint rank = i + 1;
      CreatureLeaderboard.set(creatureDataArray[i].objectEntityId, rank);
    }
  }

  function resetLeaderboard() internal {
    bytes32[][] memory creatureLBEntities = getKeysInTable(CreatureLeaderboardTableId);
    for (uint i = 0; i < creatureLBEntities.length; i++) {
      CreatureLeaderboard.deleteRecord(creatureLBEntities[i][0]);
    }
  }
}
