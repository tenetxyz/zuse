// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";

import { OwnedBy, OwnedByTableId } from "@tenet-base-world/src/codegen/tables/OwnedBy.sol";
import { Inventory, InventoryTableId } from "@tenet-base-world/src/codegen/tables/Inventory.sol";
import { InventoryObject, InventoryObjectData } from "@tenet-base-world/src/codegen/tables/InventoryObject.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { Equipped } from "@tenet-base-world/src/codegen/tables/Equipped.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { inSurroundingCube } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { getEntityAtCoord, getVoxelCoord } from "@tenet-base-world/src/Utils.sol";

abstract contract InventorySystem is System {
  function equip(bytes32 actingObjectEntityId, bytes32 inventoryId) public virtual {
    require(
      hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(actingObjectEntityId)),
      "InventorySystem: entity has no owner"
    );
    require(OwnedBy.get(actingObjectEntityId) == _msgSender(), "InventorySystem: caller does not own entity");

    require(Inventory.get(inventoryId) == actingObjectEntityId, "InventorySystem: entity does not own inventory item");

    Equipped.set(actingObjectEntityId, inventoryId);
  }

  function unequip(bytes32 actingObjectEntityId) public virtual {
    require(
      hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(actingObjectEntityId)),
      "InventorySystem: entity has no owner"
    );
    require(OwnedBy.get(actingObjectEntityId) == _msgSender(), "InventorySystem: caller does not own entity");

    Equipped.deleteRecord(actingObjectEntityId);
  }

  function transfer(
    bytes32 srcObjectEntityId,
    VoxelCoord memory dstCoord,
    bytes32 inventoryId,
    uint8 transferAmount
  ) public virtual {
    require(
      inSurroundingCube(getVoxelCoord(IStore(_world()), srcObjectEntityId), 1, dstCoord),
      "InventorySystem: destination out of range"
    );
    bytes32 dstEntityId = getEntityAtCoord(IStore(_world()), dstCoord);
    if (dstEntityId == bytes32(0)) {
      IWorld(_world()).buildTerrain(bytes32(0), dstCoord);
      dstEntityId = getEntityAtCoord(IStore(_world()), dstCoord);
    }
    bytes32 dstObjectEntityId = ObjectEntity.get(dstEntityId);
    require(dstObjectEntityId != bytes32(0), "InventorySystem: destination has no object entity");
    require(dstObjectEntityId != srcObjectEntityId, "InventorySystem: cannot transfer to self");

    require(isValidSource(srcObjectEntityId), "InventorySystem: invalid source");
    require(isValidDestination(dstObjectEntityId), "InventorySystem: invalid destination");
    require(Inventory.get(inventoryId) == srcObjectEntityId, "InventorySystem: entity does not own inventory item");

    InventoryObjectData memory inventoryObjectData = InventoryObject.get(inventoryId);
    require(inventoryObjectData.numObjects >= transferAmount, "InventorySystem: insufficient inventory amount");

    if (inventoryObjectData.numObjects == transferAmount) {
      require(!IWorld(_world()).isInventoryFull(dstObjectEntityId), "InventorySystem: destination inventory is full");
      // transfer all
      Inventory.set(inventoryId, dstObjectEntityId);
    } else {
      revert("InventorySystem: partial transfer not yet implemented");
      // TODO: implement partial transfer but keep durability
      // IWorld(_world()).addObjectToInventory(
      //   dstObjectEntityId,
      //   inventoryObjectData.objectTypeId,
      //   transferAmount,
      //   abi.decode(inventoryObjectData.objectProperties, (ObjectProperties))
      // );
      // IWorld(_world()).removeObjectFromInventory(inventoryId, transferAmount);
    }
  }

  function isValidSource(bytes32 srcObjectEntityId) internal view virtual returns (bool);

  function isValidDestination(bytes32 dstObjectEntityId) internal view virtual returns (bool);
}
