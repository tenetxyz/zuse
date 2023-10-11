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
    // Set the same terrain selector for 8 cubes around the origin
    VoxelCoord[8] memory specifiedCoords = [
      VoxelCoord({ x: 0, y: 0, z: 0 }),
      VoxelCoord({ x: -1, y: 0, z: 0 }),
      VoxelCoord({ x: 0, y: -1, z: 0 }),
      VoxelCoord({ x: -1, y: -1, z: 0 }),
      VoxelCoord({ x: 0, y: 0, z: -1 }),
      VoxelCoord({ x: -1, y: 0, z: -1 }),
      VoxelCoord({ x: 0, y: -1, z: -1 }),
      VoxelCoord({ x: -1, y: -1, z: -1 })
    ];

    BucketData[] memory spawnBuckets = new BucketData[](3);
    spawnBuckets[0] = BucketData({ id: 0, minMass: 0, maxMass: 0, energy: 0, count: 0 });
    spawnBuckets[1] = BucketData({
      id: 1,
      minMass: 1,
      maxMass: 50,
      energy: 50,
      count: uint(int((SHARD_DIM - 1) * SHARD_DIM * SHARD_DIM))
    });
    spawnBuckets[3] = BucketData({
      id: 2,
      minMass: 100,
      maxMass: 300,
      energy: 1000,
      count: uint(int(1 * SHARD_DIM * SHARD_DIM))
    });

    for (uint8 i = 0; i < 8; i++) {
      IWorld(_world()).claimShard(
        specifiedCoords[i],
        _world(),
        IWorld(_world()).getSpawnVoxelType.selector,
        spawnBuckets
      );
    }

    // setTerrainProperties(VoxelCoord[] memory coords, uint8 bucketIndex)
  }

  function getSpawnVoxelType(VoxelCoord memory coord) public view returns (bytes32) {
    (, BucketData memory bucketData) = IWorld(_world()).getTerrainProperties(coord);
    if (bucketData.id == 1) {
      VoxelCoord memory shardCoord = coordToShardCoord(coord);
      // check if the coord y is at the top of the shard
      if (shardCoord.y == SHARD_DIM - 1) {
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
