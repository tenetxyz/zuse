// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { Position, PositionData, PositionTableId } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { ReversePosition, ReversePositionTableId } from "@tenet-base-world/src/codegen/tables/ReversePosition.sol";
import { ObjectEntity, ObjectEntityTableId } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { ReverseObjectEntity, ReverseObjectEntityTableId } from "@tenet-base-world/src/codegen/tables/ReverseObjectEntity.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";
import { InventoryObject, InventoryObjectData } from "@tenet-base-world/src/codegen/tables/InventoryObject.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { getVonNeumannNeighbours, getMooreNeighbours } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { NUM_MAX_INVENTORY_SLOTS } from "@tenet-base-world/src/Constants.sol";

function positionDataToVoxelCoord(PositionData memory coord) pure returns (VoxelCoord memory) {
  return VoxelCoord(coord.x, coord.y, coord.z);
}

function getEntityIdFromObjectEntityId(IStore store, bytes32 objectEntityId) view returns (bytes32) {
  return ReverseObjectEntity.get(store, objectEntityId);
}

function getVoxelCoord(IStore store, bytes32 objectEntityId) view returns (VoxelCoord memory) {
  PositionData memory position = Position.get(store, getEntityIdFromObjectEntityId(store, objectEntityId));
  return positionDataToVoxelCoord(position);
}

function getObjectType(IStore store, bytes32 objectEntityId) view returns (bytes32) {
  return ObjectType.get(store, getEntityIdFromObjectEntityId(store, objectEntityId));
}

function getEntityAtCoord(IStore store, VoxelCoord memory coord) view returns (bytes32) {
  return ReversePosition.get(store, coord.x, coord.y, coord.z);
}

function getEntityPositionStrict(IStore store, bytes32 entityId) view returns (PositionData memory) {
  require(hasKey(store, PositionTableId, Position.encodeKeyTuple(entityId)), "Entity must have a position");
  return Position.get(store, entityId);
}

function getVoxelCoordStrict(IStore store, bytes32 entityId) view returns (VoxelCoord memory) {
  PositionData memory position = getEntityPositionStrict(store, entityId);
  return positionDataToVoxelCoord(position);
}

function getVonNeumannNeighbourEntities(
  IStore store,
  bytes32 centerEntityId
) view returns (bytes32[] memory, VoxelCoord[] memory) {
  VoxelCoord memory centerCoord = positionDataToVoxelCoord(Position.get(store, centerEntityId));
  return getVonNeumannNeighbourEntities(store, centerCoord);
}

function getVonNeumannNeighbourEntities(
  IStore store,
  VoxelCoord memory centerCoord
) view returns (bytes32[] memory, VoxelCoord[] memory) {
  VoxelCoord[] memory neighbourCoords = getVonNeumannNeighbours(centerCoord);
  bytes32[] memory neighbourEntities = new bytes32[](neighbourCoords.length);

  for (uint i = 0; i < neighbourCoords.length; i++) {
    bytes32 neighbourEntity = getEntityAtCoord(store, neighbourCoords[i]);
    if (uint256(neighbourEntity) != 0) {
      neighbourEntities[i] = neighbourEntity;
    }
  }

  return (neighbourEntities, neighbourCoords);
}

function getMooreNeighbourEntities(
  IStore store,
  bytes32 centerEntityId,
  uint8 neighbourRadius
) view returns (bytes32[] memory, VoxelCoord[] memory) {
  VoxelCoord memory centerCoord = positionDataToVoxelCoord(Position.get(store, centerEntityId));
  VoxelCoord[] memory neighbourCoords = getMooreNeighbours(centerCoord, neighbourRadius);
  bytes32[] memory neighbourEntities = new bytes32[](neighbourCoords.length);
  for (uint i = 0; i < neighbourCoords.length; i++) {
    bytes32 neighbourEntity = getEntityAtCoord(store, neighbourCoords[i]);
    if (uint256(neighbourEntity) != 0) {
      neighbourEntities[i] = neighbourEntity;
    }
  }
  return (neighbourEntities, neighbourCoords);
}

function addObjectToInventory(
  IStore store,
  bytes32 objectEntityId,
  bytes32 objectTypeId,
  uint8 numObjectsToAdd,
  ObjectProperties memory objectProperties
) {
  bytes32[][] memory inventoryIds = getKeysWithValue(store, InventoryTableId, Inventory.encode(objectEntityId));

  // Check if this object type is already in the inventory, otherwise add a new one
  bool foundExistingObject = false;
  for (uint256 i = 0; i < inventoryIds.length; i++) {
    bytes32 inventoryId = inventoryIds[i][0];
    InventoryObjectData memory inventoryObjectData = InventoryObject.get(store, inventoryId);
    if (inventoryObjectData.objectTypeId == objectTypeId) {
      foundExistingObject = true;

      // Update count
      // TODO: Check stackable
      InventoryObject.setNumObjects(store, inventoryId, inventoryObjectData.numObjects + numObjectsToAdd);

      break;
    }
  }

  if (!foundExistingObject) {
    require(inventoryIds.length < NUM_MAX_INVENTORY_SLOTS, "addObjectToInventory: Inventory is full");
    // Add new object to inventory
    bytes32 inventoryId = getUniqueEntity();
    Inventory.set(store, inventoryId, objectEntityId);
    InventoryObject.set(store, inventoryId, objectTypeId, numObjectsToAdd, abi.encode(objectProperties));
  }
}

function removeObjectFromInventory(IStore store, bytes32 inventoryId, uint8 numObjectsToRemove) {
  InventoryObjectData memory inventoryObjectData = InventoryObject.get(store, inventoryId);
  require(inventoryObjectData.numObjects >= numObjectsToRemove, "removeObjectFromInventory: Not enough objects");
  if (inventoryObjectData.numObjects > numObjectsToRemove) {
    InventoryObject.setNumObjects(store, inventoryId, inventoryObjectData.numObjects - numObjectsToRemove);
  } else {
    Inventory.deleteRecord(store, inventoryId);
    InventoryObject.deleteRecord(store, inventoryId);
  }
}
