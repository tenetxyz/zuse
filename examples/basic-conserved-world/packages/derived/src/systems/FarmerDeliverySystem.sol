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
import { BuildingLeaderboard, BuildingLeaderboardTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { FarmDeliveryLeaderboard, FarmDeliveryLeaderboardTableId, FarmDeliveryLeaderboardData } from "@tenet-derived/src/codegen/Tables.sol";
import { OriginatingChunk, OriginatingChunkTableId } from "@tenet-derived/src/codegen/Tables.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-world/src/codegen/tables/OwnedBy.sol";

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
      !hasKey(BuildingLeaderboardTableId, BuildingLeaderboard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)),
      "FarmerDeliverySystem: A builder already claimed this shard"
    );

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

  function packageForDelivery(VoxelEntity memory foodEntity) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    IStore caStore = IStore(BASE_CA_ADDRESS);

    require(
      hasKey(CAEntityMappingTableId, CAEntityMapping.encodeKeyTuple(WORLD_ADDRESS, foodEntity.entityId)),
      "packageForDelivery: no CAentity found for foodEntity"
    );

    bytes32 foodCAEntity = CAEntityMapping.get(caStore, WORLD_ADDRESS, foodEntity.entityId);

    require(
      !hasKey(OriginatingChunkTableId, OriginatingChunk.encodeKeyTuple(foodCAEntity)),
      "packageForDelivery: This food already has an originating chunk"
    );

    VoxelCoord memory coord = getVoxelCoordStrict(worldStore, foodEntity);
    VoxelCoord memory shardCoord = coordToShardCoord(coord);

    OriginatingChunk.set(foodCAEntity, shardCoord.x, shardCoord.y, shardCoord.z);
  }

  function attributePoints(int32 shardX, int32 shardY, int32 shardZ) public {
    IStore worldStore = IStore(WORLD_ADDRESS);
    IStore caStore = IStore(BASE_CA_ADDRESS);

    // 1) get all crops that are from this shard
    bytes32[][] memory plantsOriginatingFromChunk = getKeysWithValue(
      worldStore,
      OriginatingChunkTableId,
      OriginatingChunk.encode(shardX, shardY, shardZ)
    );

    uint256 numDeliveries = 0;
    uint256 totalPoints = 0;

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
        bytes32 consumerCaEntity = consumer.entityId;
        BuildingLeaderboard[] memory buildings = getKeysWithValue(
          worldStore,
          BuildingLeaderboardTableId,
          BuildingLeaderboard.encode(consumerCaEntity)
        );

        for (uint k = 0; k < buildings.length; k++) {
          totalPoints += buildings[k].likes;
          numDeliveries += 1;
        }
      }
    }

    // 3) get the current builder's likes.

    // FarmDeliveryLeaderboardData memory farmDeliveryLeaderboardData = FarmDeliveryLeaderboard.get(
    //   shardX,
    //   shardY,
    //   shardZ
    // );

    // 4) reward points to the farmer leaderboard

    FarmDeliveryLeaderboard.set(shardX, shardY, shardZ, totalPoints, numDeliveries);

    // It is ok for the farmer to get more points by waiting longer before calling this function
    // it incentivizes farmers to support builders long-term
  }
}
