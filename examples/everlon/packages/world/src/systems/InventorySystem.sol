// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { InventorySystem as InventoryProtoSystem } from "@tenet-base-world/src/systems/InventorySystem.sol";
import { getObjectType } from "@tenet-base-world/src/Utils.sol";
import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";
import { ChestObjectID, AirObjectID } from "@tenet-world/src/Constants.sol";

contract InventorySystem is InventoryProtoSystem {
  function equip(bytes32 actingObjectEntityId, bytes32 inventoryId) public override {
    super.equip(actingObjectEntityId, inventoryId);
  }

  function unequip(bytes32 actingObjectEntityId) public override {
    super.unequip(actingObjectEntityId);
  }

  function transfer(
    bytes32 srcObjectEntityId,
    VoxelCoord memory dstCoord,
    bytes32 inventoryId,
    uint8 transferAmount
  ) public override {
    super.transfer(srcObjectEntityId, dstCoord, inventoryId, transferAmount);
  }

  function isValidSource(bytes32 srcObjectEntityId) internal view override returns (bool) {
    if (hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(srcObjectEntityId))) {
      require(OwnedBy.get(srcObjectEntityId) == _msgSender(), "InventorySystem: caller does not own entity");
      return true;
    }

    bytes32 srcObjectTypeId = getObjectType(IStore(_world()), srcObjectEntityId);
    if (srcObjectTypeId == ChestObjectID) {
      return true;
    }

    return false;
  }

  function isValidDestination(bytes32 dstObjectEntityId) internal view override returns (bool) {
    if (hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(dstObjectEntityId))) {
      return true;
    }

    bytes32 dstObjectTypeId = getObjectType(IStore(_world()), dstObjectEntityId);
    if (dstObjectTypeId == ChestObjectID || dstObjectTypeId == AirObjectID) {
      return true;
    }

    return false;
  }
}
