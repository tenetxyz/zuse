// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { VoxelCoord, ObjectProperties, TerrainData } from "@tenet-utils/src/Types.sol";
import { AIR_MASS, DIRT_MASS, GRASS_MASS, BEDROCK_MASS, AirObjectID, DirtObjectID, GrassObjectID, BedrockObjectID } from "@tenet-world/src/Constants.sol";
import { SHARD_DIM } from "@tenet-world/src/Constants.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";

int32 constant NUM_LAYERS_SPAWN_GRASS = 1;
int32 constant NUM_LAYERS_SPAWN_DIRT = 8;
int32 constant NUM_LAYERS_SPAWN_BEDROCK = 1;

// TODO: Make an abstract prototype that has thw two terrain functions
contract SpawnTerrainSystem is System {
  function initSpawnTerrain() public {
    VoxelCoord[1] memory spawnCoords = [VoxelCoord({ x: 0, y: 0, z: 0 })];

    for (uint8 i = 0; i < spawnCoords.length; i++) {
      VoxelCoord memory faucetAgentCoord = VoxelCoord({
        x: ((spawnCoords[i].x + 1) * SHARD_DIM) / 2,
        y: NUM_LAYERS_SPAWN_GRASS + NUM_LAYERS_SPAWN_DIRT + NUM_LAYERS_SPAWN_BEDROCK,
        z: ((spawnCoords[i].z + 1) * SHARD_DIM) / 2
      });

      IWorld(_world()).claimShard(
        spawnCoords[i],
        _world(),
        IWorld(_world()).world_SpawnTerrainSyst_getSpawnTerrainObjectTypeId.selector,
        IWorld(_world()).world_SpawnTerrainSyst_getSpawnTerrainObjectProperties.selector,
        faucetAgentCoord
      );
    }
  }

  function getSpawnTerrainObjectTypeId(VoxelCoord memory coord) public view returns (bytes32) {
    return getSpawnTerrainObjectData(coord).objectTypeId;
  }

  function getSpawnTerrainObjectProperties(
    VoxelCoord memory coord,
    ObjectProperties memory requestedProperties
  ) public view returns (ObjectProperties memory) {
    return getSpawnTerrainObjectData(coord).properties;
  }

  function getSpawnTerrainObjectData(VoxelCoord memory coord) internal view returns (TerrainData memory) {
    ObjectProperties memory properties;
    VoxelCoord memory shardCoord = coordToShardCoord(coord, SHARD_DIM);
    if (coord.y == (shardCoord.y * SHARD_DIM)) {
      properties.mass = BEDROCK_MASS;
      properties.energy = 300;
      return TerrainData({ objectTypeId: BedrockObjectID, properties: properties });
    } else if (
      coord.y > (shardCoord.y * SHARD_DIM) &&
      coord.y <= (shardCoord.y * SHARD_DIM) + (NUM_LAYERS_SPAWN_GRASS + NUM_LAYERS_SPAWN_DIRT)
    ) {
      if (coord.y == (shardCoord.y * SHARD_DIM) + (NUM_LAYERS_SPAWN_GRASS + NUM_LAYERS_SPAWN_DIRT)) {
        properties.mass = GRASS_MASS;
        properties.energy = 100;
        return TerrainData({ objectTypeId: GrassObjectID, properties: properties });
      } else {
        properties.mass = DIRT_MASS;
        properties.energy = 50;
        return TerrainData({ objectTypeId: DirtObjectID, properties: properties });
      }
    } else {
      properties.mass = AIR_MASS;
      properties.energy = 0;
      return TerrainData({ objectTypeId: AirObjectID, properties: properties });
    }
  }
}
