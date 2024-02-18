// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";
import { InventoryObject, InventoryObjectData } from "@tenet-base-world/src/codegen/tables/InventoryObject.sol";
import { Equipped } from "@tenet-base-world/src/codegen/tables/Equipped.sol";

import { REGISTRY_ADDRESS, NUM_MAX_INVENTORY_SLOTS } from "@tenet-base-world/src/Constants.sol";
import { getStackable, getMaxUses } from "@tenet-registry/src/Utils.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

abstract contract InventorySystem is System {
  function useEquipped(bytes32 actingObjectEntityId) public virtual {
    bytes32 equippedInventoryId = Equipped.get(actingObjectEntityId);
    if (equippedInventoryId != bytes32(0)) {
      InventoryObjectData memory equippedInventoryObjectData = InventoryObject.get(equippedInventoryId);
      if (equippedInventoryObjectData.numUsesLeft > 0) {
        if (equippedInventoryObjectData.numUsesLeft == 1) {
          // Destroy equipped item
          Equipped.deleteRecord(equippedInventoryId);
          Inventory.deleteRecord(equippedInventoryId);
          InventoryObject.deleteRecord(equippedInventoryId);
        } else {
          InventoryObject.setNumUsesLeft(equippedInventoryId, equippedInventoryObjectData.numUsesLeft - 1);
        }
      } // 0 = unlimited uses
    }
  }

  function addObjectToInventory(
    bytes32 objectEntityId,
    bytes32 objectTypeId,
    uint8 numObjectsToAdd,
    ObjectProperties memory objectProperties
  ) public virtual {
    bytes32[][] memory inventoryIds = getKeysWithValue(InventoryTableId, Inventory.encode(objectEntityId));

    uint8 stackable = getStackable(IStore(REGISTRY_ADDRESS), objectTypeId);
    require(stackable > 0, "InventorySystem: Object type is not stackable");

    uint16 numUsesLeft = getMaxUses(IStore(REGISTRY_ADDRESS), objectTypeId);

    // Check if this object type is already in the inventory, otherwise add a new one
    uint8 remainingObjectsToAdd = numObjectsToAdd;
    for (uint256 i = 0; i < inventoryIds.length; i++) {
      bytes32 inventoryId = inventoryIds[i][0];
      InventoryObjectData memory inventoryObjectData = InventoryObject.get(inventoryId);

      if (inventoryObjectData.objectTypeId == objectTypeId && inventoryObjectData.numObjects < stackable) {
        uint8 newNumObjects = inventoryObjectData.numObjects + remainingObjectsToAdd;
        if (newNumObjects > stackable) {
          newNumObjects = stackable;
          remainingObjectsToAdd -= (stackable - inventoryObjectData.numObjects);
        } else {
          remainingObjectsToAdd = 0;
        }

        InventoryObject.setNumObjects(inventoryId, newNumObjects);
      }

      if (remainingObjectsToAdd == 0) {
        break;
      }
    }

    while (remainingObjectsToAdd > 0) {
      // add as manny new inventory slots per stackable limit to store the remaining objects
      require(inventoryIds.length < NUM_MAX_INVENTORY_SLOTS, "InventorySystem: Inventory is full");
      // Add new object to inventory
      bytes32 inventoryId = getUniqueEntity();
      Inventory.set(inventoryId, objectEntityId);
      uint8 newNumObjects = remainingObjectsToAdd;
      if (remainingObjectsToAdd > stackable) {
        newNumObjects = stackable;
        remainingObjectsToAdd -= stackable;
        inventoryIds = getKeysWithValue(InventoryTableId, Inventory.encode(objectEntityId));
      } else {
        remainingObjectsToAdd = 0;
      }

      InventoryObject.set(inventoryId, objectTypeId, newNumObjects, numUsesLeft, abi.encode(objectProperties));
    }
  }

  function removeObjectFromInventory(bytes32 inventoryId, uint8 numObjectsToRemove) public virtual {
    InventoryObjectData memory inventoryObjectData = InventoryObject.get(inventoryId);
    require(inventoryObjectData.numObjects >= numObjectsToRemove, "InventorySystem: Not enough objects");
    if (inventoryObjectData.numObjects > numObjectsToRemove) {
      InventoryObject.setNumObjects(inventoryId, inventoryObjectData.numObjects - numObjectsToRemove);
    } else {
      Inventory.deleteRecord(inventoryId);
      InventoryObject.deleteRecord(inventoryId);
    }
  }
}
