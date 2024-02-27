// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { InternalInventorySystem as InternalInventoryProtoSystem } from "@tenet-base-world/src/systems/InternalInventorySystem.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";
import { InventoryObject, InventoryObjectData } from "@tenet-base-world/src/codegen/tables/InventoryObject.sol";
import { ChestObjectID, AirObjectID, MAX_CHEST_SLOTS } from "@tenet-world/src/Constants.sol";
import { REGISTRY_ADDRESS, NUM_MAX_INVENTORY_SLOTS } from "@tenet-base-world/src/Constants.sol";
import { getObjectType } from "@tenet-base-world/src/Utils.sol";

contract InternalInventorySystem is InternalInventoryProtoSystem {
  function isInventoryFull(bytes32 objectEntityId) public view override returns (bool) {
    bytes32[][] memory inventoryIds = getKeysWithValue(InventoryTableId, Inventory.encode(objectEntityId));
    if (hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(objectEntityId))) {
      return inventoryIds.length >= NUM_MAX_INVENTORY_SLOTS;
    }

    bytes32 objectTypeId = getObjectType(IStore(_world()), objectEntityId);
    if (objectTypeId == ChestObjectID) {
      return inventoryIds.length >= MAX_CHEST_SLOTS;
    }

    return false;
  }

  function useEquipped(bytes32 actingObjectEntityId) public override {
    super.useEquipped(actingObjectEntityId);
  }

  function addObjectToInventory(
    bytes32 objectEntityId,
    bytes32 objectTypeId,
    uint8 numObjectsToAdd,
    ObjectProperties memory objectProperties
  ) public override {
    super.addObjectToInventory(objectEntityId, objectTypeId, numObjectsToAdd, objectProperties);
  }

  function removeObjectFromInventory(bytes32 inventoryId, uint8 numObjectsToRemove) public override {
    super.removeObjectFromInventory(inventoryId, numObjectsToRemove);
  }
}
