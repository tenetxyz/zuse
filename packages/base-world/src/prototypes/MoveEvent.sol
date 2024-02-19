// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { Event } from "@tenet-base-world/src/prototypes/Event.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { AgentMetadata } from "@tenet-base-world/src/codegen/tables/AgentMetadata.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";
import { ReverseObjectEntity } from "@tenet-base-world/src/codegen/tables/ReverseObjectEntity.sol";

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";
import { IWorldMoveEventSystem } from "@tenet-base-simulator/src/codegen/world/IWorldMoveEventSystem.sol";

abstract contract MoveEvent is Event {
  function getOldCoord(bytes memory eventData) internal pure virtual returns (VoxelCoord memory);

  function move(
    bytes32 actingObjectEntityId,
    bytes32 moveObjectTypeId,
    VoxelCoord memory newCoord,
    bytes memory eventData
  ) internal virtual returns (bytes32, bytes32) {
    VoxelCoord memory oldCoord = getOldCoord(eventData);
    bytes32 oldEntityId = getEntityAtCoord(IStore(_world()), oldCoord);
    if (uint256(oldEntityId) == 0) {
      IWorld(_world()).buildTerrain(actingObjectEntityId, oldCoord);
    }
    bytes32 newEntityId = getEntityAtCoord(IStore(_world()), newCoord);
    if (uint256(newEntityId) == 0) {
      IWorld(_world()).buildTerrain(actingObjectEntityId, newCoord);
    }
    newEntityId = super.runEvent(actingObjectEntityId, moveObjectTypeId, newCoord, eventData);
    return (oldEntityId, newEntityId);
  }

  function preEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual override {
    IWorld(_world()).approveMove(_msgSender(), actingObjectEntityId, objectTypeId, coord, eventData);
    IWorldMoveEventSystem(getSimulatorAddress()).preMoveEvent(
      actingObjectEntityId,
      objectTypeId,
      getOldCoord(eventData),
      coord
    );
  }

  function postEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes memory eventData
  ) internal virtual override {
    IWorldMoveEventSystem(getSimulatorAddress()).postMoveEvent(
      actingObjectEntityId,
      objectTypeId,
      getOldCoord(eventData),
      coord,
      ObjectEntity.get(eventEntityId)
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
    bytes32 currentObjectTypeId;
    if (isNewEntity) {
      currentObjectTypeId = IWorld(_world()).getTerrainObjectTypeId(coord);
    } else {
      currentObjectTypeId = ObjectType.get(eventEntityId);
    }
    require(currentObjectTypeId == emptyObjectId(), "MoveEvent: cannot move to non-empty object");

    VoxelCoord memory oldCoord = getOldCoord(eventData);
    bytes32 oldEntityId = getEntityAtCoord(IStore(_world()), oldCoord);
    require(uint256(oldEntityId) != 0, "MoveEvent: old entity does not exist");
    bytes32 oldObjectTypeId = ObjectType.get(oldEntityId);
    require(
      oldObjectTypeId != emptyObjectId() && oldObjectTypeId == objectTypeId,
      "MoveEvent: object type id mismatch"
    );
    bytes32 oldObjectEntityId = ObjectEntity.get(oldEntityId);
    require(uint256(oldObjectEntityId) != 0, "MoveEvent: old object entity does not exist");

    // Update object type of old entity to empty
    ObjectType.set(oldEntityId, emptyObjectId());
    ObjectType.set(eventEntityId, objectTypeId);

    // Update ObjectEntity to new coord
    // Note: this is the main move of the object pointer
    ObjectEntity.set(oldEntityId, objectEntityId);
    ReverseObjectEntity.set(objectEntityId, oldEntityId);
    ObjectEntity.set(eventEntityId, oldObjectEntityId);
    ReverseObjectEntity.set(oldObjectEntityId, eventEntityId);

    // Note: if the simulator calls move, we don't want to count that as a user
    // move, so we only update the metadata if the caller is not the simulator
    if (_msgSender() != getSimulatorAddress()) {
      if (AgentMetadata.getLastUpdateBlock(actingObjectEntityId) != block.number) {
        AgentMetadata.setLastUpdateBlock(actingObjectEntityId, block.number);
        AgentMetadata.setNumMoves(actingObjectEntityId, 1);
      } else {
        AgentMetadata.setNumMoves(actingObjectEntityId, AgentMetadata.getNumMoves(actingObjectEntityId) + 1);
      }
    }

    {
      // Transfer any dropped items to the new object
      bool hasOwner = OwnedBy.get(oldObjectEntityId) != address(0);
      bytes32[][] memory inventoryIds = getKeysWithValue(InventoryTableId, Inventory.encode(objectEntityId));
      if (hasOwner) {
        for (uint256 i = 0; i < inventoryIds.length; i++) {
          bytes32 inventoryId = inventoryIds[i][0];
          require(!IWorld(_world()).isInventoryFull(oldObjectEntityId), "InventorySystem: inventory is full");
          Inventory.set(inventoryId, oldObjectEntityId);
        }
      } else {
        require(inventoryIds.length == 0, "MoveEvent: Cannot move non-agent where there are dropped items");
      }
    }

    // We reset the eventEntityId from preRunObject
    // since collisions could have changed the eventEntityId
    // TODO: Figure out a cleaner way to handle this
    eventEntityId = IWorldMoveEventSystem(getSimulatorAddress()).onMoveEvent(
      actingObjectEntityId,
      objectTypeId,
      oldCoord,
      coord,
      objectEntityId,
      oldObjectEntityId // Note: the names here are confusing, but this is the object entity id of the moving object
      // TODO: Figure out a cleaner way to handle this
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
    bytes32 oldEntityId = getEntityAtCoord(IStore(_world()), getOldCoord(eventData));
    require(uint256(oldEntityId) != 0, "MoveEvent: old entity does not exist");

    // Need to run 2 interactions because we're moving so two entities are involved
    IWorld(_world()).runInteractions(eventEntityId);
    IWorld(_world()).runInteractions(oldEntityId);
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
