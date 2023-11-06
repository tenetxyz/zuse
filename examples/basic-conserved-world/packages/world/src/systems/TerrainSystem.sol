// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, TerrainData } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { AirVoxelID, GrassVoxelID, DirtVoxelID, BedrockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { TerrainProperties, TerrainPropertiesTableId } from "@tenet-world/src/codegen/Tables.sol";
import { getTerrainVoxelId } from "@tenet-base-ca/src/CallUtils.sol";
import { callOrRevert, staticCallOrRevert } from "@tenet-utils/src/CallUtils.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS } from "@tenet-world/src/Constants.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { console } from "forge-std/console.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { Shard, ShardData, ShardTableId } from "@tenet-world/src/codegen/tables/Shard.sol";

uint256 constant MAX_TOTAL_ENERGY_IN_SHARD = 50000000;
uint256 constant MAX_TOTAL_MASS_IN_SHARD = 50000000;

contract TerrainSystem is System {
  function getTerrainVoxel(VoxelCoord memory coord) public returns (bytes32) {
    (bytes32 voxelTypeId, ) = getTerrainVoxelFromShard(coord);
    return voxelTypeId;
  }

  function getTerrainMass(uint32 scale, VoxelCoord memory coord) public returns (uint256) {
    (, uint256 voxelMass) = getTerrainVoxelFromShard(coord);

    return voxelMass;
  }

  function getTerrainEnergy(uint32 scale, VoxelCoord memory coord) public returns (uint256) {
    (, , uint256 voxelEnergy) = getTerrainVoxelFromShard(coord);
    return voxelEnergy;
  }

  function getTerrainVelocity(uint32 scale, VoxelCoord memory coord) public view returns (VoxelCoord memory) {
    return VoxelCoord({ x: 0, y: 0, z: 0 });
  }

  function getTerrainVoxelFromShard(VoxelCoord memory coord) public returns (bytes32, uint256, uint256) {
    // use cache if possible
    if (hasKey(TerrainPropertiesTableId, TerrainProperties.encodeKeyTuple(coord.x, coord.y, coord.z))) {
      TerrainProperties memory terrainProperties = TerrainProperties.get(coord.x, coord.y, coord.z);
      uint256 voxelMass = VoxelTypeRegistry.getMass(IStore(REGISTRY_ADDRESS), terrainProperties.voxelTypeId);
      return (terrainProperties.voxelTypeId, voxelMass, terrainProperties.energy);
    }

    VoxelCoord memory shardCoord = coordToShardCoord(coord);
    require(hasKey(ShardTableId, Shard.encodeKeyTuple(shardCoord.x, shardCoord.y, shardCoord.z)), "Shard not claimed");
    ShardData memory shardData = Shard.get(shardCoord.x, shardCoord.y, shardCoord.z);
    bytes memory returnData = staticCallOrRevert(
      shardData.contractAddress,
      abi.encodeWithSelector(shardData.terrainSelector, coord),
      "shard terrainSelector"
    );
    TerrainData memory terrainData = abi.decode(returnData, (TerrainData));
    uint256 voxelMass = VoxelTypeRegistry.getMass(IStore(REGISTRY_ADDRESS), terrainData.voxelTypeId);
    if (terrainData.totalGenMass + voxelMass > MAX_TOTAL_MASS_IN_SHARD) {
      voxelMass = 0;
    } else {
      // update shard data total mass
      terrainData.totalGenMass += voxelMass;
    }
    if (terrainData.totalGenEnergy + terrainData.energy > MAX_TOTAL_ENERGY_IN_SHARD) {
      terrainData.energy = 0;
    } else {
      // update shard data total energy
      terrainData.totalGenEnergy += terrainData.energy;
    }
    Shard.set(shardCoord.x, shardCoord.y, shardCoord.z, shardData);
    TerrainProperties.set(
      coord.x,
      coord.y,
      coord.z,
      TerrainProperties({ voxelTypeId: terrainData.voxelTypeId, energy: terrainData.energy })
    );

    return (terrainData.voxelTypeId, voxelMass, terrainData.energy);
  }

  // Called by CA's on terrain gen
  function onTerrainGen(bytes32 voxelTypeId, VoxelCoord memory coord) public {}
}
