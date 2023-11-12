// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { Metadata, MetadataTableId } from "@tenet-base-world/src/codegen/tables/Metadata.sol";

import { VoxelCoord, EntityActionData } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";

abstract contract Event is System {
  function runEvent(
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual returns (bytes32) {
    preEvent(objectTypeId, coord, eventData);

    (bytes eventEntityId, EntityActionData[] memory entitiesActionData) = runEventHandler(
      objectTypeId,
      coord,
      eventData
    );

    postEvent(objectTypeId, coord, eventEntityId, eventData, entitiesActionData);

    return eventEntityId;
  }

  function preEvent(bytes32 objectTypeId, VoxelCoord memory coord, bytes memory eventData) internal virtual;

  function postEvent(
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes memory eventData,
    EntityActionData[] memory entitiesActionData
  ) internal virtual {
    processActions(entitiesActionData);

    // Clear all keys in Metadata
    bytes32[][] memory entitiesRan = getKeysInTable(MetadataTableId);
    for (uint256 i = 0; i < entitiesRan.length; i++) {
      Metadata.deleteRecord(entitiesRan[i][0]);
    }
  }

  function processActions(EntityActionData[] memory entitiesActionData) internal virtual;

  function runEventHandler(
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual returns (bytes32, EntityActionData[] memory) {
    bytes32 eventEntityId = getEntityAtCoord(coord);
    if (uint256(eventEntityId) == 0) {
      eventEntityId = getUniqueEntity();
      Position.set(eventEntityId, coord.x, coord.y, coord.z);
    }
    ObjectType.set(
      eventEntityId,
      objectTypeId
    );

    // We reset the eventEntityId from preRunObject, giving it a chance to
    // change it. eg this can happen during move
    // TODO: Figure out a cleaner way to handle this
    eventEntityId = preRunObject(objectTypeId, coord, eventEntityId, eventData);

    EntityActionData[] memory entitiesActionData = runObject(objectTypeId, coord, eventEntityId, eventData);

    postRunObject(objectTypeId, coord, eventEntityId, eventData);

    return (eventEntityId, entitiesActionData);
  }

  function preRunObject(
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes memory eventData
  ) internal virtual returns (bytes32);

  function postRunObject(
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes memory eventData
  ) internal virtual;

  function runObject(
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes memory eventData
  ) internal virtual returns (EntityActionData[] memory);
}
