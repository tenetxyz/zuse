// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { EquipSystem as EquipProtoSystem } from "@tenet-base-world/src/systems/EquipSystem.sol";

contract EquipSystem is EquipProtoSystem {
  function equip(bytes32 actingObjectEntityId, bytes32 inventoryId) public override {
    super.equip(actingObjectEntityId, inventoryId);
  }
}
