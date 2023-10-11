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

uint256 constant MAX_TOTAL_ENERGY_IN_SHARD = 1000000;
uint256 constant MAX_TOTAL_MASS_IN_SHARD = 1000000;

contract ShardSystem is System {
  function claimShard(
    VoxelCoord memory coordInShard,
    address contractAddress,
    bytes4 terrainSelector,
    BucketData[] buckets
  ) public {
    address callerAddress = _msgSender();
    VoxelCoord memory shardCoord = coordToShardCoord(coordInShard);
    require(
      !hasKey(ShardTableId, Shard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)),
      "Shard already claimed"
    );
    verifyBucketCounts(buckets);
    Shard.set(
      shardCoord.x,
      shardCoord.y,
      shardCoord.z,
      ShardData({
        claimer: callerAddress,
        contractAddress: contractAddress,
        terrainSelector: terrainSelector,
        verified: false,
        buckets: buckets
      })
    );
  }

  function setTerrainProperties(VoxelCoord[] memory coords, uint8 bucketIndex) public {
    require(coords.length > 0, "Must have at least one coord");
    address callerAddress = _msgSender();
    VoxelCoord memory shardCoord = coordToShardCoord(coords[0]);
    require(hasKey(ShardTableId, Shard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)), "Shard not claimed");
    ShardData memory shardData = Shard.get(shardCoord.x, shardCoord.y, shardCoord.z);
    require(shardData.claimer == callerAddress, "Only shard claimer can set terrain properties");
    require(!shardData.verified, "Shard already verified, cannot set terrain properties now");
    require(bucketIndex < shardData.buckets.length, "Bucket index out of range");
    for (uint256 i = 0; i < coords.length; i++) {
      require(coordToShardCoord(coords[i]) == shardCoord, "All coords must be in the same shard");
      TerrainProperties.set(coords[i].x, coords[i].y, coords[i].z, bucketIndex);
    }
  }

  function verifyShard(VoxelCoord memory shardCoord, VoxelCoord memory faucetAgentCoord) public {
    address callerAddress = _msgSender();
    require(hasKey(ShardTableId, Shard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)), "Shard not claimed");
    ShardData memory shardData = Shard.get(shardCoord.x, shardCoord.y, shardCoord.z);
    require(shardData.claimer == callerAddress, "Only shard claimer can set terrain properties");
    require(!shardData.verified, "Shard already verified, don't need to verify again");
    // Go through all the coords in the shard and make sure the counts match
    uint256[] bucketCounts = new uint256[](shardData.buckets.length);
    for (uint x = shardCoord.x * SHARD_DIM; x < (shardCoord.x + 1) * SHARD_DIM; x++) {
      for (uint y = shardCoord.x * SHARD_DIM; y < (shardCoord.x + 1) * SHARD_DIM; y++) {
        for (uint z = shardCoord.x * SHARD_DIM; z < (shardCoord.x + 1) * SHARD_DIM; z++) {
          uint256 bucketIndex = TerrainProperties.get(x, y, z);
          bucketCounts[bucketIndex] += 1;
        }
      }
    }

    for (uint256 i = 0; i < shardData.buckets.length; i++) {
      require(bucketCounts[i] == shardData.buckets[i].count, "Terrain properties do not match shard bucket counts");
    }
    Shard.setVerified(shardCoord.x, shardCoord.y, shardCoord.z, true);

    // Build a facuet entity at the faucetAgentCoord
    bytes32 voxelTypeId = FighterVoxelID;
    uint256 initMass = 1000000000; // Make faucet really high mass so its hard to mine
    uint256 initEnergy = 0;
    uint256 initStamina = STARTING_STAMINA_FROM_FAUCET * 100; // faucet entity can spawn 100 agents
    VoxelCoord memory initVelocity = VoxelCoord({ x: 0, y: 0, z: 0 });
    // This will place the agent, so it will check if the voxel there is air
    VoxelEntity memory faucetEntity = IWorld(_world()).spawnBody(
      voxelTypeId,
      faucetAgentCoord,
      bytes4(0),
      initMass,
      initEnergy,
      initVelocity,
      initStamina
    );
    OwnedBy.set(agentEntity.scale, agentEntity.entityId, address(0)); // Set owner to 0 so no one can claim it
    Faucet.set(
      faucetEntity.scale,
      faucetEntity.entityId,
      FaucetData({ claimers: new address[](0), claimerAmounts: new uint256[](0) })
    );
  }

  function verifyBucketCounts(BucketData[] buckets) internal pure {
    uint256 totalMinMass = 0;
    uint256 totalMaxMass = 0;
    uint256 totalEnergy = 0;
    for (uint256 i = 0; i < buckets.length; i++) {
      BucketData memory bucket = buckets[i];
      totalMinMass += bucket.minMass * bucket.count;
      totalMaxMass += bucket.maxMass * bucket.count;
      totalEnergy += bucket.energy * bucket.count;
    }
    require(totalMaxMass <= MAX_TOTAL_MASS_IN_SHARD, "Total max mass exceeds shard mass limit");
    require(totalEnergy <= MAX_TOTAL_ENERGY_IN_SHARD, "Total energy exceeds shard energy limit");
  }
}
