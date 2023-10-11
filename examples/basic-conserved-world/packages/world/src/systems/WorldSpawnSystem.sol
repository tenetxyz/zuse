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

contract WorldSpawnSystem is System {
  function initWorldSpawn() public {
    // Set the same terrain selector for 4 cubes around the origin
    VoxelCoord[1] memory specifiedCoords = [VoxelCoord({ x: 0, y: 0, z: 0 })];

    BucketData[] memory spawnBuckets = new BucketData[](3);
    spawnBuckets[0] = BucketData({
      id: 0,
      minMass: 0,
      maxMass: 0,
      energy: 0,
      count: uint(int((SHARD_DIM - 10) * SHARD_DIM * SHARD_DIM))
    });
    spawnBuckets[1] = BucketData({
      id: 1,
      minMass: 1,
      maxMass: 50,
      energy: 50,
      count: uint(int(9 * SHARD_DIM * SHARD_DIM))
    });
    spawnBuckets[2] = BucketData({
      id: 2,
      minMass: 100,
      maxMass: 300,
      energy: 100,
      count: uint(int(1 * SHARD_DIM * SHARD_DIM))
    });

    for (uint8 i = 0; i < specifiedCoords.length; i++) {
      IWorld(_world()).claimShard(
        specifiedCoords[i],
        _world(),
        IWorld(_world()).getSpawnVoxelType.selector,
        spawnBuckets
      );
    }

    // Set the terrain properties for the spawn buckets
    VoxelCoord[] memory bucket1Coords = new VoxelCoord[](spawnBuckets[1].count);
    uint bucket1Index = 0;
    VoxelCoord[] memory bucket2Coords = new VoxelCoord[](spawnBuckets[2].count);
    uint bucket2Index = 0;

    for (uint8 i = 0; i < specifiedCoords.length; i++) {
      VoxelCoord memory shardCoord = specifiedCoords[i];
      for (int32 x = shardCoord.x * SHARD_DIM; x < (shardCoord.x + 1) * SHARD_DIM; x++) {
        for (int32 y = shardCoord.x * SHARD_DIM; y < (shardCoord.x + 1) * SHARD_DIM; y++) {
          for (int32 z = shardCoord.x * SHARD_DIM; z < (shardCoord.x + 1) * SHARD_DIM; z++) {
            // Make all the layers below y = 10
            if (y == shardCoord.y) {
              bucket2Coords[bucket2Index] = VoxelCoord({ x: x, y: y, z: z });
              bucket2Index++;
            } else if (y > shardCoord.y && y <= shardCoord.y + 9) {
              bucket1Coords[bucket1Index] = VoxelCoord({ x: x, y: y, z: z });
              bucket1Index++;
            }
          }
        }
      }
    }
    IWorld(_world()).setTerrainProperties(bucket1Coords, 1);
    IWorld(_world()).setTerrainProperties(bucket2Coords, 2);
    // IWorld(_world()).verifyShard(specifiedCoords[0]);
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
