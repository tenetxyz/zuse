// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, BucketData } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { AirVoxelID, GrassVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { TerrainProperties, TerrainPropertiesTableId } from "@tenet-world/src/codegen/Tables.sol";
import { getTerrainVoxelId } from "@tenet-base-ca/src/CallUtils.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS, SHARD_DIM } from "@tenet-world/src/Constants.sol";
import { coordToShardCoord } from "@tenet-world/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";

int32 constant NUM_LAYERS_SPAWN_DIRT = 8;
int32 constant NUM_LAYERS_SPAWN_BEDROCK = 1;
int32 constant NUM_LAYERS_SPAWN_GRASS = 1;
int32 constant NUM_LAYERS_SPAWN_AIR = 60;

uint256 constant AIR_BUCKET_INDEX = 0;
uint256 constant DIRT_AND_GRASS_BUCKET_INDEX = 1;
uint256 constant BEDROCK_BUCKET_INDEX = 2;

contract WorldSpawnSystem is System {
  function initWorldSpawn() public {
    VoxelCoord[1] memory spawnCoords = [VoxelCoord({ x: 0, y: 0, z: 0 })];

    BucketData[] memory spawnBuckets = new BucketData[](3);
    spawnBuckets[AIR_BUCKET_INDEX] = BucketData({
      id: 0,
      minMass: 0,
      maxMass: 0,
      energy: 0,
      count: uint(int(NUM_LAYERS_SPAWN_AIR * SHARD_DIM * SHARD_DIM)),
      actualCount: 0
    });
    spawnBuckets[DIRT_AND_GRASS_BUCKET_INDEX] = BucketData({
      id: 1,
      minMass: 0,
      maxMass: 50,
      energy: 50,
      count: uint(int((SHARD_DIM - (NUM_LAYERS_SPAWN_AIR + NUM_LAYERS_SPAWN_BEDROCK)) * SHARD_DIM * SHARD_DIM)),
      actualCount: 0
    });
    spawnBuckets[BEDROCK_BUCKET_INDEX] = BucketData({
      id: 2,
      minMass: 100,
      maxMass: 300,
      energy: 100,
      count: uint(int(NUM_LAYERS_SPAWN_BEDROCK * SHARD_DIM * SHARD_DIM)),
      actualCount: 0
    });

    for (uint8 i = 0; i < spawnCoords.length; i++) {
      VoxelCoord memory faucetAgentCoord = VoxelCoord({
        x: ((spawnCoords[i].x + 1) * SHARD_DIM) / 2,
        y: NUM_LAYERS_SPAWN_GRASS + NUM_LAYERS_SPAWN_DIRT + NUM_LAYERS_SPAWN_BEDROCK,
        z: ((spawnCoords[i].z + 1) * SHARD_DIM) / 2
      });

      IWorld(_world()).claimShard(
        spawnCoords[i],
        _world(),
        IWorld(_world()).getSpawnVoxelType.selector,
        IWorld(_world()).getSpawnBucketIndex.selector,
        spawnBuckets,
        faucetAgentCoord
      );
    }
  }

  function getSpawnBucketIndex(VoxelCoord memory coord) public view returns (uint256) {
    VoxelCoord memory shardCoord = coordToShardCoord(coord);
    // check if coord.y is at bottom of shard
    if (coord.y == (shardCoord.y * SHARD_DIM)) {
      return BEDROCK_BUCKET_INDEX;
    } else if (
      coord.y > (shardCoord.y * SHARD_DIM) &&
      coord.y <= (shardCoord.y * SHARD_DIM) + (SHARD_DIM - (NUM_LAYERS_SPAWN_AIR + NUM_LAYERS_SPAWN_BEDROCK))
    ) {
      return DIRT_AND_GRASS_BUCKET_INDEX;
    } else {
      return AIR_BUCKET_INDEX;
    }
  }

  function getSpawnVoxelType(BucketData memory bucketData, VoxelCoord memory coord) public view returns (bytes32) {
    VoxelCoord memory shardCoord = coordToShardCoord(coord);
    if (bucketData.id == DIRT_AND_GRASS_BUCKET_INDEX) {
      int32 topLayer = (shardCoord.y * SHARD_DIM) + (NUM_LAYERS_SPAWN_GRASS + NUM_LAYERS_SPAWN_DIRT);
      if (coord.y == topLayer) {
        return GrassVoxelID;
      } else if (coord.y < topLayer) {
        return DirtVoxelID;
      }
    } else if (bucketData.id == BEDROCK_BUCKET_INDEX) {
      return BedrockVoxelID;
    }
    return AirVoxelID;
  }
}
