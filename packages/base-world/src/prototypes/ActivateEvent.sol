// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { Event } from "@tenet-base-world/src/prototypes/Event.sol";

import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";

import { VoxelCoord, EntityActionData } from "@tenet-utils/src/Types.sol";
import { MoveEventData } from "@tenet-base-world/src/Types.sol";
import { getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";

abstract contract ActivateEvent is Event {
  function activate(
    bytes32 actingObjectEntityId,
    bytes32 activateObjectTypeId,
    VoxelCoord memory activateCoord,
    bytes memory eventData
  ) internal virtual returns (bytes32) {
    bytes32 activateEntityId = getEntityAtCoord(IStore(_world()), activateCoord);
    if (uint256(activateEntityId) == 0) {
      IWorld(_world()).build(actingObjectEntityId, activateObjectTypeId, activateCoord);
    }
    return super.runEvent(actingObjectEntityId, activateObjectTypeId, activateCoord, eventData);
  }

  function preEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual override {
    IWorld(_world()).approveActivate(_msgSender(), actingObjectEntityId, objectTypeId, coord, eventData);
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
    require(ObjectType.get(eventEntityId) == objectTypeId, "ActivateEvent: object type id mismatch");
    // Note: if we want objects to return some property data, we could do that here in the future
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
