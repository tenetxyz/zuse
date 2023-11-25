// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { Event } from "@tenet-base-world/src/prototypes/Event.sol";

import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";

import { MoveEventData } from "@tenet-base-world/src/Types.sol";
import { VoxelCoord, EntityActionData } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";

abstract contract MoveEvent is Event {
  function getOldCoord(bytes memory eventData) internal pure virtual returns (VoxelCoord memory) {
    MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
    return moveEventData.oldCoord;
  }

  function move(
    bytes32 actingObjectEntityId,
    bytes32 moveObjectTypeId,
    VoxelCoord memory newCoord,
    bytes memory eventData
  ) internal virtual returns (bytes32, bytes32) {
    VoxelCoord memory oldCoord = getOldCoord(eventData);
    bytes32 oldEntityId = getEntityAtCoord(IStore(_world()), oldCoord);
    if (uint256(oldEntityId) == 0) {
      IWorld(_world()).build(actingObjectEntityId, moveObjectTypeId, oldCoord);
    }
    bytes32 newEntityId = super.runEvent(actingObjectEntityId, moveObjectTypeId, newCoord, eventData);
    return (oldEntityId, newEntityId);
  }

  function preEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual override {
    IWorld(_world()).approveMove(_msgSender(), actingObjectEntityId, objectTypeId, coord, eventData);
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
    bytes32 currentObjectTypeId;
    if (isNewEntity) {
      currentObjectTypeId = IWorld(_world()).getTerrainObjectTypeId(coord);
    } else {
      currentObjectTypeId = ObjectType.get(objectTypeId);
    }
    require(currentObjectTypeId == emptyObjectId(), "MoveEvent: cannot move to non-empty object");

    bytes32 oldEntityId = getEntityAtCoord(IStore(_world()), getOldCoord(eventData));
    require(oldEntityId != uint256(0), "MoveEvent: old entity does not exist");
    bytes32 oldObjectTypeId = ObjectType.get(oldEntityId);
    require(
      oldObjectTypeId != emptyObjectId() && oldObjectTypeId == objectTypeId,
      "MoveEvent: object type id mismatch"
    );
    bytes32 oldObjectEntityId = ObjectEntity.get(oldEntityId);
    require(oldObjectEntityId != uint256(0), "MoveEvent: old object entity does not exist");

    // Update object type of old entity to empty
    ObjectType.set(oldEntityId, emptyObjectId());

    // Update ObjectEntity to new coord
    // Note: this is the main move of the object pointer
    ObjectEntity.set(oldEntityId, objectEntityId);
    ObjectEntity.set(eventEntityId, oldObjectEntityId);

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
    bytes32 oldEntityId = getEntityAtCoord(IStore(_world()), getOldCoord(eventData));
    require(oldEntityId != uint256(0), "MoveEvent: old entity does not exist");

    // Need to run 2 interactions because we're moving so two entities are involved
    EntityActionData[] memory oldEntityActionData = IWorld(_world()).runInteractions(oldEntityId);
    EntityActionData[] memory newEntityActionData = IWorld(_world()).runInteractions(eventEntityId);
    EntityActionData[] memory entityActionData = new EntityActionData[](
      oldEntityActionData.length + newEntityActionData.length
    );
    for (uint256 i = 0; i < oldEntityActionData.length; i++) {
      entityActionData[i] = oldEntityActionData[i];
    }
    for (uint256 i = 0; i < newEntityActionData.length; i++) {
      entityActionData[i + oldEntityActionData.length] = newEntityActionData[i];
    }
    return entityActionData;
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
