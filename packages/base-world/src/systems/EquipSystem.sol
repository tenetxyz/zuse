// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";

import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";
import { Equipped } from "@tenet-base-world/src/codegen/tables/Equipped.sol";

abstract contract EquipSystem is System {
  function equip(bytes32 actingObjectEntityId, bytes32 inventoryId) public virtual {
    require(hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(actingObjectEntityId)), "EquipSystem: entity has no owner");
    require(OwnedBy.get(actingObjectEntityId) == _msgSender(), "EquipSystem: caller does not own entity");

    require(Inventory.get(inventoryId) == actingObjectEntityId, "EquipSystem: entity does not own inventory item");

    Equipped.set(actingObjectEntityId, inventoryId);
  }
}
