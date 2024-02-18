// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { Event } from "@tenet-base-world/src/prototypes/Event.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";
import { InventoryObject, InventoryObjectData } from "@tenet-base-world/src/codegen/tables/InventoryObject.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { IWorldMineEventSystem } from "@tenet-base-simulator/src/codegen/world/IWorldMineEventSystem.sol";
import { ISimInitSystem } from "@tenet-base-simulator/src/codegen/world/ISimInitSystem.sol";

abstract contract MineEvent is Event {
  function mine(
    bytes32 actingObjectEntityId,
    bytes32 mineObjectTypeId,
    VoxelCoord memory mineCoord,
    bytes memory eventData
  ) internal virtual returns (bytes32) {
    return super.runEvent(actingObjectEntityId, mineObjectTypeId, mineCoord, eventData);
  }

  function preEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual override {
    IWorld(_world()).approveMine(_msgSender(), actingObjectEntityId, objectTypeId, coord, eventData);
    IWorldMineEventSystem(getSimulatorAddress()).preMineEvent(actingObjectEntityId, objectTypeId, coord);
  }

  function postEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes memory eventData
  ) internal virtual override {
    IWorldMineEventSystem(getSimulatorAddress()).postMineEvent(
      actingObjectEntityId,
      objectTypeId,
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
    require(
      currentObjectTypeId != emptyObjectId() && currentObjectTypeId == objectTypeId,
      "MineEvent: Object type id mismatch"
    );

    // Add to inventory
    if (actingObjectEntityId != bytes32(0)) {
      ObjectProperties memory inventoryObjectProperties;
      if (isNewEntity) {
        ObjectProperties memory requestedProperties = IWorld(_world()).enterWorld(objectTypeId, coord, objectEntityId);
        inventoryObjectProperties = IWorld(_world()).getTerrainObjectProperties(coord, requestedProperties);
        ISimInitSystem(getSimulatorAddress()).initObject(objectEntityId, inventoryObjectProperties);
      } else {
        inventoryObjectProperties = IWorld(_world()).getObjectProperties(objectEntityId);
      }

      IWorld(_world()).addObjectToInventory(actingObjectEntityId, objectTypeId, 1, inventoryObjectProperties);
    }

    IWorld(_world()).exitWorld(objectTypeId, coord, objectEntityId);

    ObjectType.set(eventEntityId, emptyObjectId());

    IWorldMineEventSystem(getSimulatorAddress()).onMineEvent(actingObjectEntityId, objectTypeId, coord, objectEntityId);

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
  ) internal virtual override {
    bool hasOwner = OwnedBy.get(objectEntityId) != address(0);
    if (hasOwner) {
      // Remove owner
      OwnedBy.deleteRecord(objectEntityId);
    }
  }
}
