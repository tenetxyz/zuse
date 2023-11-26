// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";

import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";

// Note: We pass in actingObjectEntityId due to running on the EVM,
// but we can use the equivalent of _msgSender() once Zuse is its own computer

// Note: eventData is so custom worlds can have their own data being passed around
// and we need it for MoveEvent to pass in the oldCoord
abstract contract Event is System {
  function runEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual returns (bytes32) {
    preEvent(actingObjectEntityId, objectTypeId, coord, eventData);

    bytes32 eventEntityId = runEventHandler(actingObjectEntityId, objectTypeId, coord, eventData);

    postEvent(actingObjectEntityId, objectTypeId, coord, eventEntityId, eventData);

    return eventEntityId;
  }

  function getSimulatorAddress() internal pure virtual returns (address);

  function emptyObjectId() internal pure virtual returns (bytes32);

  function preEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual;

  function postEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes memory eventData
  ) internal virtual;

  function runEventHandler(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual returns (bytes32) {
    bytes32 eventEntityId = getEntityAtCoord(IStore(_world()), coord);
    bytes32 objectEntityId;
    bool isNewEntity = uint256(eventEntityId) == 0;
    if (isNewEntity) {
      eventEntityId = getUniqueEntity();
      Position.set(eventEntityId, coord.x, coord.y, coord.z);
      objectEntityId = getUniqueEntity();
      ObjectEntity.set(eventEntityId, objectEntityId);
    } else {
      objectEntityId = ObjectEntity.get(eventEntityId);
    }

    // We reset the eventEntityId from preRunObject, giving it a chance to
    // change it. eg this can happen during move
    // TODO: Figure out a cleaner way to handle this
    eventEntityId = preRunObject(
      actingObjectEntityId,
      objectTypeId,
      coord,
      eventEntityId,
      objectEntityId,
      isNewEntity,
      eventData
    );

    runObject(actingObjectEntityId, objectTypeId, coord, eventEntityId, objectEntityId, eventData);

    postRunObject(actingObjectEntityId, objectTypeId, coord, eventEntityId, objectEntityId, eventData);

    return (eventEntityId);
  }

  function preRunObject(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes32 objectEntityId,
    bool isNewEntity,
    bytes memory eventData
  ) internal virtual returns (bytes32);

  function postRunObject(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes32 objectEntityId,
    bytes memory eventData
  ) internal virtual;

  function runObject(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes32 objectEntityId,
    bytes memory eventData
  ) internal virtual;
}
