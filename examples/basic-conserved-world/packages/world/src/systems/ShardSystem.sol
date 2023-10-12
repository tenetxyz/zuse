// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, BucketData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { AirVoxelID, GrassVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { Faucet, FaucetData, OwnedBy, Shard, ShardData, ShardTableId, TerrainProperties, TerrainPropertiesTableId } from "@tenet-world/src/codegen/Tables.sol";
import { getTerrainVoxelId } from "@tenet-base-ca/src/CallUtils.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS } from "@tenet-world/src/Constants.sol";
import { FighterVoxelID, STARTING_STAMINA_FROM_FAUCET } from "@tenet-level1-ca/src/Constants.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { SHARD_DIM } from "@tenet-utils/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";

uint256 constant MAX_TOTAL_ENERGY_IN_SHARD = 50000000;
uint256 constant MAX_TOTAL_MASS_IN_SHARD = 50000000;

contract ShardSystem is System {
  function claimShard(
    VoxelCoord memory coordInShard,
    address contractAddress,
    bytes4 terrainSelector,
    bytes4 bucketSelector,
    BucketData[] memory buckets,
    VoxelCoord memory faucetAgentCoord
  ) public {
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
        claimer: tx.origin,
        contractAddress: contractAddress,
        terrainSelector: terrainSelector,
        bucketSelector: bucketSelector,
        buckets: abi.encode(buckets)
      })
    );

    setFaucetAgent(faucetAgentCoord);
  }

  function verifyBucketCounts(BucketData[] memory buckets) internal pure {
    uint256 totalMinMass = 0;
    uint256 totalMaxMass = 0;
    uint256 totalEnergy = 0;
    uint256 totalBucketCount = 0;
    for (uint256 i = 0; i < buckets.length; i++) {
      BucketData memory bucket = buckets[i];
      totalMinMass += bucket.minMass * bucket.count;
      totalMaxMass += bucket.maxMass * bucket.count;
      totalEnergy += bucket.energy * bucket.count;
      totalBucketCount += bucket.count;
      require(bucket.actualCount == 0, "Initial count must be 0");
    }
    require(totalMaxMass <= MAX_TOTAL_MASS_IN_SHARD, "Total max mass exceeds shard mass limit");
    require(totalEnergy <= MAX_TOTAL_ENERGY_IN_SHARD, "Total energy exceeds shard energy limit");
    require(totalBucketCount == uint(int(SHARD_DIM * SHARD_DIM * SHARD_DIM)), "Not enough buckets");
  }

  function setFaucetAgent(VoxelCoord memory faucetAgentCoord) internal {
    // Build a facuet entity at the faucetAgentCoord
    bytes32 voxelTypeId = FighterVoxelID;
    uint256 initMass = 1000000000; // Make faucet really high mass so its hard to mine
    uint256 initEnergy = 1000000000;
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
    OwnedBy.set(faucetEntity.scale, faucetEntity.entityId, address(0)); // Set owner to 0 so no one can claim it
    Faucet.set(
      faucetEntity.scale,
      faucetEntity.entityId,
      FaucetData({ claimers: new address[](0), claimerAmounts: new uint256[](0) })
    );
  }

  function setTerrainProperties(VoxelCoord[] memory coords, uint8 bucketIndex) public {
    require(coords.length > 0, "Must have at least one coord");
    address callerAddress = tx.origin;
    VoxelCoord memory shardCoord = coordToShardCoord(coords[0]);
    require(hasKey(ShardTableId, Shard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)), "Shard not claimed");
    ShardData memory shardData = Shard.get(shardCoord.x, shardCoord.y, shardCoord.z);
    require(shardData.claimer == callerAddress, "Only shard claimer can set terrain properties");
    BucketData[] memory buckets = abi.decode(shardData.buckets, (BucketData[]));
    require(bucketIndex < buckets.length, "Bucket index out of range");
    uint256[] memory newBucketCounts = new uint256[](buckets.length);
    for (uint256 i = 0; i < coords.length; i++) {
      require(voxelCoordsAreEqual(coordToShardCoord(coords[i]), shardCoord), "All coords must be in the same shard");
      require(
        !hasKey(TerrainPropertiesTableId, TerrainProperties.encodeKeyTuple(coords[i].x, coords[i].y, coords[i].z)),
        "Terrain properties already set"
      );
      TerrainProperties.set(coords[i].x, coords[i].y, coords[i].z, bucketIndex);
      newBucketCounts[bucketIndex] += 1;
    }

    // Check bucket count
    for (uint i = 0; i < newBucketCounts.length; i++) {
      BucketData memory bucketData = buckets[i];
      require(bucketData.actualCount + newBucketCounts[i] <= bucketData.count, "Bucket count exceeded");
      bucketData.actualCount += newBucketCounts[i];
      buckets[i] = bucketData;
    }

    Shard.setBuckets(shardCoord.x, shardCoord.y, shardCoord.z, abi.encode(buckets));
  }
}
