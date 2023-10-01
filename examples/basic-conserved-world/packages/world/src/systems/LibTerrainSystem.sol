// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { AirVoxelID, GrassVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { ShardProperties, ShardPropertiesData, ShardPropertiesTableId, BodyPhysics, BodyPhysicsData, VoxelTypeProperties } from "@tenet-world/src/codegen/Tables.sol";
import { getTerrainVoxelId } from "@tenet-base-ca/src/CallUtils.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { BASE_CA_ADDRESS } from "@tenet-world/src/Constants.sol";
import { SHARD_DIM } from "@tenet-level1-ca/src/Constants.sol";
import { coordToShardCoord } from "@tenet-level1-ca/src/Utils.sol";

struct BucketData {
  uint256 minMass;
  uint256 maxMass;
  uint256 energy;
  uint8 priority;
}

int256 constant Y_AIR_THRESHOLD = 100;
int256 constant Y_GROUND_THRESHOLD = 0;

contract LibTerrainSystem is System {
  function getTerrainBodyPhysicsData(
    address caAddress,
    VoxelCoord memory coord
  ) public returns (bytes32, BodyPhysicsData memory) {
    BodyPhysicsData memory data;

    bytes32 voxelTypeId = getTerrainVoxelId(caAddress, coord);
    (uint256 terrainMass, uint256 terrainEnergy) = getTerrainProperties(coord);

    data.mass = terrainMass;
    data.energy = terrainEnergy;
    data.velocity = abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 }));
    data.lastUpdateBlock = block.number;

    return (voxelTypeId, data);
  }

  function calculateMinMaxNosie(
    VoxelCoord memory shardCoord,
    int256 denom,
    uint8 precision
  ) internal view returns (int128, int128) {
    int128 minNoise = type(int128).max; // Initialize to the maximum possible int128 value
    int128 maxNoise = type(int128).min; // Initialize to the minimum possible int128 value

    int128[] memory perlinValues = new int128[](uint(int(SHARD_DIM * SHARD_DIM * SHARD_DIM)));
    uint256 index = 0;

    for (int256 x = shardCoord.x * SHARD_DIM; x < (shardCoord.x + 1) * SHARD_DIM; x++) {
      for (int256 y = shardCoord.y * SHARD_DIM; y < (shardCoord.y + 1) * SHARD_DIM; y++) {
        for (int256 z = shardCoord.z * SHARD_DIM; z < (shardCoord.z + 1) * SHARD_DIM; z++) {
          int128 perlinValue = IWorld(_world()).noise2d(x, z, denom, precision);
          perlinValues[index] = perlinValue;
          index++;
          // Update minNoise and maxNoise if necessary
          if (perlinValue < minNoise) {
            minNoise = perlinValue;
          }
          if (perlinValue > maxNoise) {
            maxNoise = perlinValue;
          }
        }
      }
    }

    return (minNoise, maxNoise);
  }

  function determineBucketIndex(
    uint256 numBuckets,
    int128 massNoise,
    VoxelCoord memory coord,
    int256 denom,
    uint8 precision
  ) internal pure returns (uint256) {
    int128 minNoise = type(int128).max; // Initialize to the maximum possible int128 value
    int128 maxNoise = type(int128).min; // Initialize to the minimum possible int128 value
    // Step 1: Calculate All Perlin Noise Values and Find Min/Max Values
    VoxelCoord memory shardCoord = coordToShardCoord(coord);
    if (hasKey(ShardPropertiesTableId, ShardProperties.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z))) {
      ShardPropertiesData memory shardProperties = ShardProperties.get(shardCoord.x, shardCoord.y, shardCoord.z);
      minNoise = shardProperties.minNoise;
      maxNoise = shardProperties.maxNoise;
    } else {
      (minNoise, maxNoise) = calculateMinMaxNosie(shardCoord, denom, precision);
      ShardProperties.set(
        shardCoord.x,
        shardCoord.y,
        shardCoord.z,
        ShardPropertiesData({ minNoise: minNoise, maxNoise: maxNoise })
      );
    }

    // Step 2: Split up the noise values into buckets
    // Determine the range of values for each bucket based on the min and max values found in Step 1.
    int128 bucketRange = (maxNoise - minNoise) / int128(numBuckets);

    // Step 3: Return which index the massNoise falls into
    // Calculate the bucket index for the given `massNoise` value based on the determined bucket ranges.
    uint256 bucketIndex = uint256((massNoise - minNoise) / bucketRange);
    return bucketIndex;
  }

  function getTerrainProperties(VoxelCoord memory coord) public returns (BucketData memory) {
    BucketData[] memory buckets = new BucketData[](2);
    buckets[0] = BucketData({ minMass: 10, maxMass: 50, energy: 100, priority: 1 });
    buckets[1] = BucketData({ minMass: 100, maxMass: 300, energy: 50, priority: 0 });

    // Define some scaling factors for the noise functions
    int256 denom = 999;
    uint8 precision = 64;

    // Convert VoxelCoord to int256 for use with the noise functions
    int256 x = int256(coord.x);
    int256 y = int256(coord.y);
    int256 z = int256(coord.z);

    // Step 1: Determine whether we are in air or ground region
    bool hasMassEnergy = false;
    {
      int128 airGroundNoise = IWorld(_world()).noise(x, y, z, denom, precision);
      bool isAir = y > Y_AIR_THRESHOLD;
      bool isGround = y < Y_GROUND_THRESHOLD;
      bool isTerrain = !isAir && !isGround && airGroundNoise > 0;
      hasMassEnergy = isTerrain || isGround;
    }

    if (hasMassEnergy) {
      // Step 2: Determine the mass of the ground
      int128 massNoise = IWorld(_world()).noise2d(x, z, denom, precision);

      // Determine which bucket the voxel falls into based on its mass
      uint256 bucketIndex = determineBucketIndex(buckets.length, massNoise, coord, denom, precision);
      require(bucketIndex < buckets.length, "Bucket index out of bounds");

      // Return the corresponding BucketData
      return buckets[bucketIndex];
    }

    return buckets[0];
  }

  // Called by CA's on terrain gen
  function onTerrainGen(bytes32 voxelTypeId, VoxelCoord memory coord) public {
    // address caAddress = _msgSender();
    (uint256 terrainMass, uint256 terrainEnergy) = getTerrainProperties(coord);
    require(terrainMass == VoxelTypeProperties.get(voxelTypeId), "Terrain mass does not match voxel type mass");
  }

  function setTerrainSelector(VoxelCoord memory coord, address contractAddress, bytes4 terrainSelector) public {
    // TODO: Make this be any CA address
    address caAddress = BASE_CA_ADDRESS;
    safeCall(
      caAddress,
      abi.encodeWithSignature(
        "setTerrainSelector((int32,int32,int32),address,bytes4)",
        coord,
        contractAddress,
        terrainSelector
      ),
      string(abi.encode("setTerrainSelector ", coord, " ", terrainSelector))
    );
  }
}
