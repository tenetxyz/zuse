// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

import { ISimInitSystem } from "@tenet-base-simulator/src/codegen/world/ISimInitSystem.sol";
import { Position, ObjectType, ObjectEntity, Faucet, FaucetData, OwnedBy, TerrainProperties, TerrainPropertiesTableId } from "@tenet-world/src/codegen/Tables.sol";
import { TerrainData, TerrainSectionData } from "@tenet-world/src/Types.sol";

import { safeStaticCall, safeCall } from "@tenet-utils/src/CallUtils.sol";
import { SIMULATOR_ADDRESS, SHARD_DIM, AIR_MASS, DIRT_MASS, GRASS_MASS, BEDROCK_MASS, AirObjectID, DirtObjectID, GrassObjectID, BedrockObjectID, FaucetObjectID } from "@tenet-world/src/Constants.sol";
import { TerrainSystem as TerrainProtoSystem } from "@tenet-base-world/src/systems/TerrainSystem.sol";
import { coordToShardCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";

int32 constant NUM_LAYERS_SPAWN_GRASS = 1;
int32 constant NUM_LAYERS_SPAWN_DIRT = 8;
int32 constant NUM_LAYERS_SPAWN_BEDROCK = 1;

contract TerrainSystem is TerrainProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function emptyObjectId() internal pure override returns (bytes32) {
    return AirObjectID;
  }

  // TODO: Make this only callable once
  function spawnInitialFaucets() public {
    VoxelCoord memory initialFaucetCoord1 = VoxelCoord(50, 10, 50);
    setFaucetAgent(initialFaucetCoord1);
  }

  function setFaucetAgent(VoxelCoord memory coord) internal {
    bytes32 objectTypeId = FaucetObjectID;

    // Create entity
    bytes32 eventEntityId = getUniqueEntity();
    Position.set(eventEntityId, coord.x, coord.y, coord.z);
    ObjectType.set(eventEntityId, objectTypeId);
    bytes32 objectEntityId = getUniqueEntity();
    ObjectEntity.set(eventEntityId, objectEntityId);

    // This will place the agent, so it will check if the object there is air
    ObjectProperties memory faucetProperties = IWorld(_world()).enterWorld(objectTypeId, coord, objectEntityId);
    ISimInitSystem(SIMULATOR_ADDRESS).initObject(objectEntityId, faucetProperties);

    // TODO: Make this the world contract, so that FaucetSystem can build using it
    OwnedBy.set(objectEntityId, address(0)); // Set owner to 0 so no one can claim it
    Faucet.set(objectEntityId, FaucetData({ claimers: new address[](0), claimerAmounts: new uint256[](0) }));
  }

  function getTerrainObjectTypeId(VoxelCoord memory coord) public view override returns (bytes32) {
    return getTerrainObjectData(coord).objectTypeId;
  }

  function getTerrainObjectProperties(
    VoxelCoord memory coord,
    ObjectProperties memory requestedProperties
  ) public override returns (ObjectProperties memory) {
    ObjectProperties memory objectProperties;
    // use cache if possible
    if (hasKey(TerrainPropertiesTableId, TerrainProperties.encodeKeyTuple(coord.x, coord.y, coord.z))) {
      bytes memory encodedTerrainProperties = TerrainProperties.get(coord.x, coord.y, coord.z);
      return abi.decode(encodedTerrainProperties, (ObjectProperties));
    }

    objectProperties = getTerrainObjectData(coord).properties;

    TerrainProperties.set(coord.x, coord.y, coord.z, abi.encode(objectProperties));

    return objectProperties;
  }

  function getTerrainObjectData(VoxelCoord memory coord) internal view returns (TerrainData memory) {
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
