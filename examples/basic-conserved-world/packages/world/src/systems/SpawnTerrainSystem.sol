// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { AirVoxelID, GrassVoxelID, DirtVoxelID, BedrockVoxelID, TerrainData } from "@tenet-level1-ca/src/Constants.sol";
import { TerrainProperties, TerrainPropertiesTableId } from "@tenet-world/src/codegen/Tables.sol";
import { getTerrainVoxelId } from "@tenet-base-ca/src/CallUtils.sol";
import { callOrRevert, staticCallOrRevert } from "@tenet-utils/src/CallUtils.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS } from "@tenet-world/src/Constants.sol";
import { SHARD_DIM } from "@tenet-utils/src/Constants.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { console } from "forge-std/console.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";

int32 constant NUM_LAYERS_SPAWN_DIRT = 8;
int32 constant NUM_LAYERS_SPAWN_BEDROCK = 1;
int32 constant NUM_LAYERS_SPAWN_GRASS = 1;

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
        IWorld(_world()).getSpawnVoxelType.selector,
        faucetAgentCoord
      );
    }
  }

  function getSpawnVoxelType(VoxelCoord memory coord) public view returns (TerrainData) {
    VoxelCoord memory shardCoord = coordToShardCoord(coord);
    if (coord.y == (shardCoord.y * SHARD_DIM)) {
      return TerrainData({ voxelTypeId: BedrockVoxelID, energy: 300 });
    } else if (
      coord.y > (shardCoord.y * SHARD_DIM) &&
      coord.y <= (shardCoord.y * SHARD_DIM) + (NUM_LAYERS_SPAWN_GRASS + NUM_LAYERS_SPAWN_DIRT)
    ) {
      if (coord.y == (shardCoord.y * SHARD_DIM) + (NUM_LAYERS_SPAWN_GRASS + NUM_LAYERS_SPAWN_DIRT)) {
        return TerrainData({ voxelTypeId: GrassVoxelID, energy: 100 });
      } else {
        return TerrainData({ voxelTypeId: DirtVoxelID, energy: 50 });
      }
    } else {
      return TerrainData({ voxelTypeId: AirVoxelID, energy: 0 });
    }
  }
}
