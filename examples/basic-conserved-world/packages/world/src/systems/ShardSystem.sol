// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { AirVoxelID, GrassVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { Faucet, FaucetData, OwnedBy, Shard, ShardData, ShardTableId, TerrainProperties, TerrainPropertiesTableId } from "@tenet-world/src/codegen/Tables.sol";
import { getTerrainVoxelId } from "@tenet-base-ca/src/CallUtils.sol";
import { callOrRevert, staticCallOrRevert } from "@tenet-utils/src/CallUtils.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS } from "@tenet-world/src/Constants.sol";
import { FaucetVoxelID, STARTING_STAMINA_FROM_FAUCET, STARTING_HEALTH_FROM_FAUCET } from "@tenet-level1-ca/src/Constants.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { SHARD_DIM } from "@tenet-utils/src/Constants.sol";
import { console } from "forge-std/console.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";

uint256 constant NUM_AGENTS_PER_FAUCET = 100;

contract ShardSystem is System {
  function claimShard(
    VoxelCoord memory coordInShard,
    address contractAddress,
    bytes4 terrainSelector,
    VoxelCoord memory faucetAgentCoord
  ) public {
    VoxelCoord memory shardCoord = coordToShardCoord(coordInShard);
    require(
      !hasKey(ShardTableId, Shard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)),
      "Shard already claimed"
    );
    Shard.set(
      shardCoord.x,
      shardCoord.y,
      shardCoord.z,
      ShardData({
        claimer: tx.origin,
        contractAddress: contractAddress,
        terrainSelector: terrainSelector,
        totalGenMass: 0,
        totalGenEnergy: 0
      })
    );

    setFaucetAgent(faucetAgentCoord);
  }

  function setFaucetAgent(VoxelCoord memory faucetAgentCoord) internal {
    // Build a facuet entity at the faucetAgentCoord
    bytes32 voxelTypeId = FaucetVoxelID;
    uint256 initMass = 1000000000; // Make faucet really high mass so its hard to mine
    uint256 initEnergy = 1000000000;
    uint256 initStamina = STARTING_STAMINA_FROM_FAUCET * NUM_AGENTS_PER_FAUCET;
    uint256 initHealth = STARTING_HEALTH_FROM_FAUCET * NUM_AGENTS_PER_FAUCET;
    VoxelCoord memory initVelocity = VoxelCoord({ x: 0, y: 0, z: 0 });
    // This will place the agent, so it will check if the voxel there is air
    VoxelEntity memory faucetEntity = IWorld(_world()).spawnBody(
      voxelTypeId,
      faucetAgentCoord,
      bytes4(0),
      initMass,
      initEnergy,
      initVelocity,
      initStamina,
      initHealth
    );
    OwnedBy.set(faucetEntity.scale, faucetEntity.entityId, address(0)); // Set owner to 0 so no one can claim it
    Faucet.set(
      faucetEntity.scale,
      faucetEntity.entityId,
      FaucetData({ claimers: new address[](0), claimerAmounts: new uint256[](0) })
    );
  }
}
