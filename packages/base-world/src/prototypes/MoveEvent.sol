// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { Event } from "./Event.sol";
import { VoxelCoord, VoxelEntity, EntityEventData } from "@tenet-utils/src/Types.sol";
import { MoveEventData } from "@tenet-base-world/src/Types.sol";
import { Position, PositionTableId } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeData } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";

abstract contract MoveEvent is Event {
  function move(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual returns (VoxelEntity memory, VoxelEntity memory) {
    VoxelEntity memory newVoxelEntity = super.runEvent(voxelTypeId, coord, eventData);
    MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
    bytes32 oldEntityId = getEntityAtCoord(newVoxelEntity.scale, moveEventData.oldCoord);
    VoxelEntity memory oldVoxelEntity = VoxelEntity({ scale: newVoxelEntity.scale, entityId: oldEntityId });
    return (oldVoxelEntity, newVoxelEntity);
  }

  function preEvent(bytes32 voxelTypeId, VoxelCoord memory coord, bytes memory eventData) internal virtual override {
    IWorld(_world()).approveMove(_msgSender(), voxelTypeId, coord, eventData);
  }

  function runEventHandlerForParent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {}

  function getParentEventData(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData,
    bytes32 childVoxelTypeId,
    VoxelCoord memory childCoord
  ) internal override returns (bytes memory) {
    return eventData;
  }

  function runEventHandlerForIndividualChildren(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    uint8 childIdx,
    bytes32 childVoxelTypeId,
    VoxelCoord memory newChildCoord,
    bytes memory eventData
  ) internal virtual override {
    uint32 scale = eventVoxelEntity.scale;
    bytes memory rawChildMoveEventData = getChildEventData(
      voxelTypeId,
      coord,
      eventVoxelEntity,
      eventData,
      childIdx,
      childVoxelTypeId,
      newChildCoord
    );
    MoveEventData memory childMoveEventData = abi.decode(eventData, (MoveEventData));
    bytes32 childVoxelEntity = getEntityAtCoord(scale - 1, childMoveEventData.oldCoord);
    if (childVoxelEntity != 0) {
      runEventHandler(
        VoxelType.getVoxelTypeId(scale - 1, childVoxelEntity),
        newChildCoord,
        true,
        false,
        rawChildMoveEventData
      );
    }
  }

  function getChildEventData(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData,
    uint8 childIdx,
    bytes32 childVoxelTypeId,
    VoxelCoord memory childCoord
  ) internal override returns (bytes memory) {
    MoveEventData memory childMoveEventData = abi.decode(eventData, (MoveEventData));
    VoxelCoord[] memory eightBlockVoxelCoords = calculateChildCoords(2, childMoveEventData.oldCoord);
    childMoveEventData.oldCoord = eightBlockVoxelCoords[childIdx];
    return abi.encode(childMoveEventData);
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
  ) internal virtual override returns (EntityEventData[] memory) {
    uint32 scale = eventVoxelEntity.scale;
    MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
    bytes32 oldEntityId = getEntityAtCoord(scale, moveEventData.oldCoord);
    VoxelEntity memory oldVoxelEntity = VoxelEntity({ scale: scale, entityId: oldEntityId });

    // Need to run 2 interactions because we're moving so two entities are involved
    // Note: for MoveEvents, we're only using the entity event data from where the new entity is placed
    IWorld(_world()).runCA(caAddress, oldVoxelEntity, bytes4(0));
    return IWorld(_world()).runCA(caAddress, eventVoxelEntity, bytes4(0));
  }

  function postRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {}
}
