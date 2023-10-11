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
import { Shard, ShardData, ShardTableId } from "@tenet-world/src/codegen/tables/Shard.sol";

contract TerrainSystem is System {
  function getTerrainVoxel(VoxelCoord memory coord) public returns (bytes32) {
    (ShardData memory shardData, BucketData memory bucketData) = getCachedBucketOrSet(coord);
    return getTerrainVoxelFromShard(shardData, bucketData, coord);
  }

  function getTerrainMass(uint32 scale, VoxelCoord memory coord) public returns (uint256) {
    (ShardData memory shardData, BucketData memory bucketData) = getCachedBucketOrSet(coord);
    bytes32 voxelTypeId = getTerrainVoxelFromShard(shardData, bucketData, coord);

    uint256 voxelMass = VoxelTypeRegistry.getMass(IStore(REGISTRY_ADDRESS), voxelTypeId);
    return voxelMass;
  }

  function getTerrainEnergy(uint32 scale, VoxelCoord memory coord) public returns (uint256) {
    // Bucket solution
    (, BucketData memory bucketData) = getCachedBucketOrSet(coord);
    return bucketData.energy;
  }

  function getTerrainVelocity(uint32 scale, VoxelCoord memory coord) public view returns (VoxelCoord memory) {
    return VoxelCoord({ x: 0, y: 0, z: 0 });
  }

  function getTerrainVoxelFromShard(
    ShardData memory shardData,
    BucketData memory bucketData,
    VoxelCoord memory coord
  ) public view returns (bytes32) {
    bytes memory returnData = safeStaticCall(
      shardData.contractAddress,
      abi.encodeWithSelector(shardData.terrainSelector, bucketData, coord),
      "shard terrainSelector"
    );
    return abi.decode(returnData, (bytes32));
  }

  function getCachedBucketOrSet(VoxelCoord memory coord) public returns (ShardData memory, BucketData memory) {
    VoxelCoord memory shardCoord = coordToShardCoord(coord);
    require(hasKey(ShardTableId, Shard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)), "Shard not claimed");
    ShardData memory shardData = Shard.get(shardCoord.x, shardCoord.y, shardCoord.z);
    BucketData[] memory buckets = abi.decode(shardData.buckets, (BucketData[]));
    bool cachedBucketExists = hasKey(
      TerrainPropertiesTableId,
      TerrainProperties.encodeKeyTuple(coord.x, coord.y, coord.z)
    );
    if (cachedBucketExists) {
      uint256 cachedIndex = TerrainProperties.get(coord.x, coord.y, coord.z);
      return (shardData, buckets[cachedIndex]);
    }
    bytes memory returnData = safeStaticCall(
      shardData.contractAddress,
      abi.encodeWithSelector(shardData.bucketSelector, coord),
      "shard bucketSelector"
    );
    uint256 bucketIndex = abi.decode(returnData, (uint256));
    // Check bucket count
    BucketData memory bucketData = buckets[bucketIndex];
    require(bucketData.actualCount < bucketData.count, "Bucket count exceeded");
    TerrainProperties.set(coord.x, coord.y, coord.z, bucketIndex);
    // update bucket data actual count
    bucketData.actualCount += 1;
    buckets[bucketIndex] = bucketData;
    Shard.setBuckets(shardCoord.x, shardCoord.y, shardCoord.z, abi.encode(buckets));
    return (shardData, buckets[bucketIndex]);
  }

  // Called by CA's on terrain gen
  function onTerrainGen(bytes32 voxelTypeId, VoxelCoord memory coord) public {
    // Bucket solution
    (, BucketData memory bucketData) = getCachedBucketOrSet(coord);
    uint256 voxelMass = VoxelTypeRegistry.getMass(IStore(REGISTRY_ADDRESS), voxelTypeId);
    require(
      voxelMass >= bucketData.minMass && voxelMass <= bucketData.maxMass,
      "Terrain mass does not match voxel type mass"
    );
  }
}
