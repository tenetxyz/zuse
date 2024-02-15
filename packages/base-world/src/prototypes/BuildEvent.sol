// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { Event } from "@tenet-base-world/src/prototypes/Event.sol";

import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";
import { InventoryObject } from "@tenet-base-world/src/codegen/tables/InventoryObject.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { IWorldBuildEventSystem } from "@tenet-base-simulator/src/codegen/world/IWorldBuildEventSystem.sol";
import { ISimInitSystem } from "@tenet-base-simulator/src/codegen/world/ISimInitSystem.sol";

abstract contract BuildEvent is Event {
  function getInventoryId(bytes memory eventData) internal pure virtual returns (bytes32);

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
    if (isNewEntity) {
      bytes32 terrainObjectTypeId = IWorld(_world()).getTerrainObjectTypeId(coord);
      require(
        terrainObjectTypeId == emptyObjectId() || terrainObjectTypeId == objectTypeId,
        "BuildEvent: Terrain object type id does not match"
      );
    } else {
      require(ObjectType.get(eventEntityId) == emptyObjectId(), "BuildEvent: Object type id is not empty");

      bytes32[][] memory inventoryIds = getKeysWithValue(InventoryTableId, Inventory.encode(objectEntityId));
      require(inventoryIds.length == 0, "BuildEvent: Cannot build where there are dropped items");
    }
    ObjectProperties memory requestedProperties = IWorld(_world()).enterWorld(objectTypeId, coord, objectEntityId);
    if (isNewEntity) {
      ObjectProperties memory properties = IWorld(_world()).getTerrainObjectProperties(coord, requestedProperties);
      ISimInitSystem(getSimulatorAddress()).initObject(objectEntityId, properties);
    }

    ObjectType.set(eventEntityId, objectTypeId);

    address caller = _msgSender();
    if (caller != _world() && caller != getSimulatorAddress()) {
      bytes32 inventoryId = getInventoryId(eventData);
      Inventory.deleteRecord(inventoryId);
      InventoryObject.deleteRecord(inventoryId);
    }

    IWorldBuildEventSystem(getSimulatorAddress()).onBuildEvent(
      actingObjectEntityId,
      objectTypeId,
      coord,
      objectEntityId,
      requestedProperties,
      isNewEntity
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
