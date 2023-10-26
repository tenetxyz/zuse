// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-derived/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Plant, PlantData, PlantStage } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { PlantConsumer } from "@tenet-pokemon-extension/src/Types.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { CAEntityReverseMapping, CAEntityReverseMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, BodySimData } from "@tenet-utils/src/Types.sol";
import { Position, PositionData } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeTableId } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { WORLD_ADDRESS, BASE_CA_ADDRESS } from "@tenet-derived/src/Constants.sol";
import { getEntitySimData } from "@tenet-world/src/CallUtils.sol";
import { getEntityAtCoord, getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";
import { getNeighbourEntities } from "@tenet-simulator/src/Utils.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { console } from "forge-std/console.sol";
import { BuildingLeaderboard, BuildingLeaderboardTableId, BuildingLeaderboardData } from "@tenet-derived/src/codegen/Tables.sol";
import { ClaimedShard } from "@tenet-derived/src/codegen/Tables.sol";
import { FarmDeliveryLeaderboard, FarmDeliveryLeaderboardTableId, FarmDeliveryLeaderboardData } from "@tenet-derived/src/codegen/Tables.sol";
import { OriginatingChunk, OriginatingChunkTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-world/src/codegen/tables/OwnedBy.sol";
import { getCAVoxelType } from "@tenet-base-ca/src/Utils.sol";
import { PlantVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";

struct EntityLikes {
  int32 x;
  int32 y;
  int32 z;
  uint256 likes;
}

contract FarmerDeliverySystem is System {
  function claimFarmShard(VoxelEntity memory agentEntity) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    IStore caStore = IStore(BASE_CA_ADDRESS);
    require(
      hasKey(worldStore, OwnedByTableId, OwnedBy.encodeKeyTuple(agentEntity.scale, agentEntity.entityId)) &&
        OwnedBy.get(worldStore, agentEntity.scale, agentEntity.entityId) == _msgSender(),
      "You do not own this entity"
    );
    VoxelCoord memory coord = getVoxelCoordStrict(worldStore, agentEntity);
    VoxelCoord memory shardCoord = coordToShardCoord(coord);

    require(
      !hasKey(
        FarmDeliveryLeaderboardTableId,
        FarmDeliveryLeaderboard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)
      ),
      "FarmerDeliverySystem: A farmer already claimed this shard"
    );

    bytes32 agentCAEntity = CAEntityMapping.get(caStore, WORLD_ADDRESS, agentEntity.entityId);
    // bytes32[] memory emptyArray = new bytes32[](0);

    FarmDeliveryLeaderboard.set(shardCoord.x, shardCoord.y, shardCoord.z, 0, 0, agentCAEntity);
  }

  function packageForDelivery(VoxelEntity[] memory foodEntities) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    IStore caStore = IStore(BASE_CA_ADDRESS);

    for (uint64 i = 0; i < foodEntities.length; i++) {
      VoxelEntity memory foodEntity = foodEntities[i];
      require(
        hasKey(CAEntityMappingTableId, CAEntityMapping.encodeKeyTuple(WORLD_ADDRESS, foodEntity.entityId)),
        "packageForDelivery: no CAentity found for foodEntity"
      );

      bytes32 foodCAEntity = CAEntityMapping.get(caStore, WORLD_ADDRESS, foodEntity.entityId);

      bytes32 voxelType = getCAVoxelType(foodCAEntity);
      require(voxelType == PlantVoxelID, "packageForDelivery: foodEntity is not a food");

      require(
        !hasKey(OriginatingChunkTableId, OriginatingChunk.encodeKeyTuple(foodCAEntity)),
        "packageForDelivery: This food already has an originating chunk"
      );

      VoxelCoord memory coord = getVoxelCoordStrict(worldStore, foodEntity);
      VoxelCoord memory shardCoord = coordToShardCoord(coord);

      OriginatingChunk.set(foodCAEntity, shardCoord.x, shardCoord.y, shardCoord.z);
    }
  }

  function attributePoints(VoxelCoord memory shardCoord) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    IStore caStore = IStore(BASE_CA_ADDRESS);

    // 1) get all crops that are from this shard
    bytes32[][] memory plantsOriginatingFromChunk = getKeysWithValue(
      OriginatingChunkTableId,
      OriginatingChunk.encode(shardCoord.x, shardCoord.y, shardCoord.z)
    );

    uint256 numDeliveries = 0;
    uint256 totalPoints = 0;
    console.log("hi");

    for (uint i = 0; i < plantsOriginatingFromChunk.length; i++) {
      bytes32 plantEntity = plantsOriginatingFromChunk[i][0];
      // 2) filter for crops that have been eaten
      PlantConsumer[] memory consumers = abi.decode(
        Plant.getConsumers(caStore, WORLD_ADDRESS, plantEntity),
        (PlantConsumer[])
      );

      for (uint j = 0; j < consumers.length; j++) {
        // 3) get the total number of likes that this builder has accrued
        PlantConsumer memory consumer = consumers[j];
        bytes memory claimedShardBytes = ClaimedShard.get(consumer.entityId);
        VoxelCoord memory claimedShard = abi.decode(claimedShardBytes, (VoxelCoord));
        totalPoints += BuildingLeaderboard.getLikedBy(claimedShard.x, claimedShard.y, claimedShard.z).length;
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
