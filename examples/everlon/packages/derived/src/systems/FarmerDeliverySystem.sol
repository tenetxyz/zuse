// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { VoxelCoord, ObjectProperties, ElementType } from "@tenet-utils/src/Types.sol";

import { MonumentClaimedArea, MonumentClaimedAreaData, MonumentClaimedAreaTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { ClaimedShard } from "@tenet-derived/src/codegen/Tables.sol";
import { FarmDeliveryLeaderboard, FarmDeliveryLeaderboardData, FarmDeliveryLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { OriginatingChunk, OriginatingChunkTableId } from "@tenet-derived/src/codegen/Tables.sol";

import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { ObjectEntity, ObjectEntityTableId } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";

import { getObjectProperties } from "@tenet-base-world/src/CallUtils.sol";
import { positionDataToVoxelCoord, getEntityIdFromObjectEntityId, getVoxelCoord, getObjectType } from "@tenet-base-world/src/Utils.sol";

import { WORLD_ADDRESS } from "@tenet-derived/src/Constants.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { SHARD_DIM } from "@tenet-world/src/Constants.sol";

import { Creature, CreatureData } from "@tenet-creatures/src/codegen/tables/Creature.sol";
import { Plant, PlantData } from "@tenet-farming/src/codegen/tables/Plant.sol";
import { PlantConsumer } from "@tenet-farming/src/Types.sol";
import { Farmer } from "@tenet-farming/src/codegen/tables/Farmer.sol";
import { PlantObjectID } from "@tenet-farming/src/Constants.sol";

struct EntityLikes {
  int32 x;
  int32 y;
  int32 z;
  uint256 likes;
}

contract FarmerDeliverySystem is System {
  function claimFarmShard(bytes32 agentObjectEntityId) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    require(
      hasKey(worldStore, OwnedByTableId, OwnedBy.encodeKeyTuple(agentObjectEntityId)) &&
        OwnedBy.get(worldStore, agentObjectEntityId) == _msgSender(),
      "FarmerDeliverySystem: You do not own this entity"
    );
    VoxelCoord memory coord = getVoxelCoord(worldStore, agentObjectEntityId);
    VoxelCoord memory shardCoord = coordToShardCoord(coord, SHARD_DIM);

    require(
      !hasKey(
        FarmDeliveryLeaderboardTableId,
        FarmDeliveryLeaderboard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)
      ),
      "FarmerDeliverySystem: A farmer already claimed this shard"
    );

    FarmDeliveryLeaderboard.set(
      shardCoord.x,
      shardCoord.y,
      shardCoord.z,
      FarmDeliveryLeaderboardData({ totalPoints: 0, numDeliveries: 0, agentObjectEntityId: agentObjectEntityId })
    );
  }

  function packageForDelivery(bytes32[] memory foodObjectEntities) public {
    IStore worldStore = IStore(WORLD_ADDRESS);

    for (uint256 i = 0; i < foodObjectEntities.length; i++) {
      bytes32 objectTypeId = getObjectType(worldStore, foodObjectEntities[i]);
      require(objectTypeId == PlantObjectID, "FarmerDeliverySystem: foodEntity is not a plant");

      if (hasKey(OriginatingChunkTableId, OriginatingChunk.encodeKeyTuple(foodObjectEntities[i]))) {
        // This plant already has an originating chunk. so don't set it's originating chunk again
        continue;
      }

      VoxelCoord memory coord = getVoxelCoord(worldStore, foodObjectEntities[i]);
      VoxelCoord memory shardCoord = coordToShardCoord(coord, SHARD_DIM);

      OriginatingChunk.set(foodObjectEntities[i], shardCoord.x, shardCoord.y, shardCoord.z);
    }
  }

  function attributePoints(VoxelCoord memory shardCoord) public {
    IStore worldStore = IStore(WORLD_ADDRESS);

    // 1) get all crops that are from this shard
    bytes32[][] memory plantsOriginatingFromChunk = getKeysWithValue(
      OriginatingChunkTableId,
      OriginatingChunk.encode(shardCoord.x, shardCoord.y, shardCoord.z)
    );

    uint256 numDeliveries = 0;
    uint256 totalPoints = 0;

    for (uint i = 0; i < plantsOriginatingFromChunk.length; i++) {
      bytes32 plantObjectEntityId = plantsOriginatingFromChunk[i][0];
      // 2) filter for crops that have been eaten
      PlantConsumer[] memory consumers = abi.decode(
        Plant.getConsumers(worldStore, WORLD_ADDRESS, plantObjectEntityId),
        (PlantConsumer[])
      );

      for (uint j = 0; j < consumers.length; j++) {
        // 3) get the total number of likes that this builder has accrued
        PlantConsumer memory consumer = consumers[j];
        bytes memory claimedShardBytes = ClaimedShard.get(consumer.objectEntityId);
        VoxelCoord memory claimedShard = abi.decode(claimedShardBytes, (VoxelCoord));
        // totalPoints += MonumentClaimedArea.getLikedBy(claimedShard.x, claimedShard.y, claimedShard.z).length;
        numDeliveries += 1;
      }
    }

    // 4) reward points to the farmer leaderboard

    FarmDeliveryLeaderboard.setTotalPoints(shardCoord.x, shardCoord.y, shardCoord.z, totalPoints);
    FarmDeliveryLeaderboard.setNumDeliveries(shardCoord.x, shardCoord.y, shardCoord.z, numDeliveries);

    // It is ok for the farmer to get more points by waiting longer before calling this function
    // it incentivizes farmers to support builders long-term
  }
}
