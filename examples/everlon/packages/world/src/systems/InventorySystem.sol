// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { InventorySystem as InventoryProtoSystem } from "@tenet-base-world/src/systems/InventorySystem.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

contract InventorySystem is InventoryProtoSystem {
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
