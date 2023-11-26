// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { Event } from "@tenet-base-world/src/prototypes/Event.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { IWorldBuildEventSystem } from "@tenet-base-simulator/src/codegen/world/IWorldBuildEventSystem.sol";
import { ISimInitSystem } from "@tenet-base-simulator/src/codegen/world/ISimInitSystem.sol";

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
    IWorldBuildEventSystem(getSimulatorAddress()).preBuildEvent(actingObjectEntityId, objectTypeId, coord);
  }

  function postEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes memory eventData
  ) internal virtual override {
    IWorldBuildEventSystem(getSimulatorAddress()).postBuildEvent(
      actingObjectEntityId,
      objectTypeId,
      coord,
      eventEntityId
    );
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
      ObjectProperties memory properties = IWorld(_world()).getTerrainObjectProperties(coord, requestedProperties);
      ISimInitSystem(getSimulatorAddress()).initObject(objectEntityId, properties);
    }

    IWorldBuildEventSystem(getSimulatorAddress()).onBuildEvent(
      actingObjectEntityId,
      objectTypeId,
      coord,
      eventEntityId,
      requestedProperties
    );

    return eventEntityId;
  }

  function runObject(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes32 objectEntityId,
    bytes memory eventData
  ) internal virtual override {
    IWorld(_world()).runInteractions(eventEntityId);
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
