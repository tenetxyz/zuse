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

contract WorldSpawnSystem is System {
  function initWorldSpawn() public {
    VoxelCoord[1] memory spawnCoords = [VoxelCoord({ x: 0, y: 0, z: 0 })];

    BucketData[] memory spawnBuckets = new BucketData[](3);
    spawnBuckets[0] = BucketData({
      id: 0,
      minMass: 0,
      maxMass: 0,
      energy: 0,
      count: uint(
        int(
          (SHARD_DIM - (NUM_LAYERS_SPAWN_GRASS + NUM_LAYERS_SPAWN_DIRT + NUM_LAYERS_SPAWN_BEDROCK)) *
            SHARD_DIM *
            SHARD_DIM
        )
      )
    });
    spawnBuckets[1] = BucketData({
      id: 1,
      minMass: 1,
      maxMass: 50,
      energy: 50,
      count: uint(int((NUM_LAYERS_SPAWN_GRASS + NUM_LAYERS_SPAWN_DIRT) * SHARD_DIM * SHARD_DIM))
    });
    spawnBuckets[2] = BucketData({
      id: 2,
      minMass: 100,
      maxMass: 300,
      energy: 100,
      count: uint(int(NUM_LAYERS_SPAWN_BEDROCK * SHARD_DIM * SHARD_DIM))
    });

    for (uint8 i = 0; i < spawnCoords.length; i++) {
      IWorld(_world()).claimShard(spawnCoords[i], _world(), IWorld(_world()).getSpawnVoxelType.selector, spawnBuckets);
    }
  }

  function getSpawnVoxelType(VoxelCoord memory coord) public view returns (bytes32) {
    (, BucketData memory bucketData) = IWorld(_world()).getTerrainProperties(coord);
    if (bucketData.id == 1) {
      VoxelCoord memory shardCoord = coordToShardCoord(coord);
      // check if the coord y is at the top of the shard
      if (coord.y == (shardCoord.y + 1) * SHARD_DIM - 1) {
        return GrassVoxelID;
      } else {
        return DirtVoxelID;
      }
    } else if (bucketData.id == 2) {
      return BedrockVoxelID;
    }
    return AirVoxelID;
  }
}
