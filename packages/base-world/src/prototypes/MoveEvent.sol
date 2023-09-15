// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { Event } from "./Event.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { MoveEventData } from "@tenet-base-world/src/Types.sol";
import { Position, PositionTableId } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeData } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";

abstract contract MoveEvent is Event {
  // Called by CA
  function moveVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bool moveChildren,
    bool moveParent
  ) public virtual returns (VoxelEntity memory, VoxelEntity memory) {
    VoxelEntity memory newVoxelEntity = super.runEventHandler(
      voxelTypeId,
      newCoord,
      moveChildren,
      moveParent,
      abi.encode(MoveEventData({ oldCoord: oldCoord }))
    );
    bytes32 oldEntityId = getEntityAtCoord(newVoxelEntity.scale, oldCoord);
    VoxelEntity memory oldVoxelEntity = VoxelEntity({
      scale: newVoxelEntity.scale,
      entityId: oldEntityId
    });
    return (newVoxelEntity, oldVoxelEntity);
  }

  function preEvent(bytes32 voxelTypeId, VoxelCoord memory coord, bytes memory eventData) internal virtual override {}

  function postEvent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {}

  function runEventHandlerForParent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {}

  function runEventHandlerForIndividualChildren(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes32 childVoxelTypeId,
    VoxelCoord memory newChildCoord,
    bytes memory eventData
  ) internal virtual override {
    uint32 scale = eventVoxelEntity.scale;
    MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
    bytes32 childVoxelEntity = getEntityAtCoord(scale - 1, moveEventData.oldCoord);
    if (childVoxelEntity != 0) {
      runEventHandler(VoxelType.getVoxelTypeId(scale - 1, childVoxelEntity), newChildCoord, true, false, eventData);
    }
  }

  function runEventHandlerForChildren(
    bytes32 voxelTypeId,
    VoxelTypeRegistryData memory voxelTypeData,
    VoxelCoord memory newCoord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {
    // Read the ChildTypes in this CA address
    bytes32[] memory childVoxelTypeIds = voxelTypeData.childVoxelTypeIds;
    // TODO: Make this general by using cube root
    require(childVoxelTypeIds.length == 8, "Invalid length of child voxel type ids");
    // TODO: move this to a library
    MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
    VoxelCoord[] memory eightBlockVoxelCoords = calculateChildCoords(2, moveEventData.oldCoord);
    VoxelCoord[] memory newEightBlockVoxelCoords = calculateChildCoords(2, newCoord);
    for (uint8 i = 0; i < 8; i++) {
      runEventHandlerForIndividualChildren(
        voxelTypeId,
        newCoord,
        eventVoxelEntity,
        childVoxelTypeIds[i],
        newEightBlockVoxelCoords[i],
        abi.encode(MoveEventData({ oldCoord: eightBlockVoxelCoords[i] }))
      );
    }
  }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory newCoord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {
    uint32 scale = eventVoxelEntity.scale;
    MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
    IWorld(_world()).moveCA(caAddress, eventVoxelEntity, voxelTypeId, moveEventData.oldCoord, newCoord);

    bytes32 oldVoxelEntity = getEntityAtCoord(scale, moveEventData.oldCoord);
    require(uint256(oldVoxelEntity) != 0, "No voxel entity at old coord");

    CAVoxelTypeData memory oldCAVoxelType = CAVoxelType.get(IStore(caAddress), _world(), oldVoxelEntity);
    VoxelType.set(scale, oldVoxelEntity, oldCAVoxelType.voxelTypeId, oldCAVoxelType.voxelVariantId);
  }

  function runCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {
    uint32 scale = eventVoxelEntity.scale;
    MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
    bytes32 oldEntityId = getEntityAtCoord(scale, moveEventData.oldCoord);
    VoxelEntity memory oldVoxelEntity = VoxelEntity({
      scale: scale,
      entityId: oldEntityId
    });

    // Need to run 2 interactions because we're moving so two entities are involved
    IWorld(_world()).runCA(caAddress, oldVoxelEntity, bytes4(0));
    IWorld(_world()).runCA(caAddress, eventVoxelEntity, bytes4(0));
  }

  function postRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {}
}