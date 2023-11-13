// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

import { Position, PositionData } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

abstract contract TerrainSystem is System {
  function getSimulatorAddress() internal pure virtual returns (address);

  function emptyObjectId() internal pure virtual returns (bytes32);

  function getTerrainObjectTypeId(VoxelCoord memory coord) public virtual returns (bytes32);

  function getTerrainObjectProperties(
    ObjectProperties memory requestedProperties
  ) public virtual returns (ObjectProperties memory);

  function createTerrainEntity(bytes32 objectTypeId, VoxelCoord memory coord) public returns (bytes32, bytes32) {
    // TODO: require caller can only be world or sim
    bytes32 terrainObjectTypeId = getTerrainObjectTypeId(coord);
    require(
      terrainObjectTypeId == emptyVoxelId() || terrainObjectTypeId == objectTypeId,
      "Invalid object type id on createTerrainEntity"
    );
    bytes32 newEntityId = getUniqueEntity();
    Position.set(newEntityId, coord.x, coord.y, coord.z);
    bytes32 newObjectEntityId = getUniqueEntity();
    ObjectEntity.set(newEntityId, newObjectEntityId);

    ObjectProperties memory requestedProperties = IWorld(_world()).enterWorld(objectTypeId, coord, newObjectEntityId);
    ObjectProperties memory properties = getTerrainObjectProperties(requestedProperties);
    // Set voxel type
    // initEntity(SIMULATOR_ADDRESS, eventVoxelEntity, initMass, initEnergy, initVelocity);
    // {
    //   InteractionSelector[] memory interactionSelectors = getInteractionSelectors(
    //     IStore(REGISTRY_ADDRESS),
    //     voxelTypeId
    //   );
    //   if (interactionSelectors.length > 1) {
    //     initAgent(SIMULATOR_ADDRESS, eventVoxelEntity, initStamina, initHealth);
    //   }
    // }
    return (newEntityId, newObjectEntityId);
  }
}
