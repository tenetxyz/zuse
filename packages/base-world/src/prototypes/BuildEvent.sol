// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { Event } from "@tenet-base-world/src/prototypes/Event.sol";

import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";

import { VoxelCoord, EntityActionData, ObjectProperties } from "@tenet-utils/src/Types.sol";

abstract contract BuildEvent is Event {
  function build(
    bytes32 actingObjectEntityId,
    bytes32 buildObjectTypeId,
    VoxelCoord memory buildCoord,
    bytes memory eventData
  ) internal virtual returns (bytes32) {
    return super.runEvent(actingObjectEntityId, buildObjectTypeId, buildCoord, eventData);
  }

  function preEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual override {
    IWorld(_world()).approveBuild(_msgSender(), actingObjectEntityId, objectTypeId, coord, eventData);
  }

  function preRunObject(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes32 objectEntityId,
    bool isNewEntity,
    bytes memory eventData
  ) internal virtual override returns (bytes32) {
    if (isNewEntity) {
      bytes32 terrainObjectTypeId = IWorld(_world()).getTerrainObjectTypeId(coord);
      require(
        terrainObjectTypeId == emptyObjectId() || terrainObjectTypeId == objectTypeId,
        "BuildEvent: Terrain object type id does not match"
      );
    } else {
      require(ObjectType.get(objectTypeId) == emptyObjectId(), "BuildEvent: Object type id is not empty");
    }
    ObjectProperties memory requestedProperties = IWorld(_world()).enterWorld(objectTypeId, coord, objectEntityId);
    if (isNewEntity) {
      ObjectProperties memory properties = IWorld(_world()).getTerrainObjectProperties(requestedProperties);
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
    }

    return eventEntityId;
  }

  function runObject(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes32 objectEntityId,
    bytes memory eventData
  ) internal virtual override returns (EntityActionData[] memory) {
    return IWorld(_world()).runInteractions(eventEntityId);
  }

  function postRunObject(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes32 objectEntityId,
    bytes memory eventData
  ) internal virtual override {}
}
