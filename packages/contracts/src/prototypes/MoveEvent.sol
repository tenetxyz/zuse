// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { Event } from "./Event.sol";
import { VoxelCoord, BodyEntity } from "@tenet-utils/src/Types.sol";
import { MoveEventData } from "@tenet-contracts/src/Types.sol";
import { WorldConfig, OwnedBy, Position, PositionTableId, BodyType, BodyTypeData, OfSpawn, Spawn, SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "@tenet-contracts/src/Utils.sol";
import { CABodyType, CABodyTypeData } from "@tenet-base-ca/src/codegen/tables/CABodyType.sol";
import { BodyTypeRegistry, BodyTypeRegistryData } from "@tenet-registry/src/codegen/tables/BodyTypeRegistry.sol";

abstract contract MoveEvent is Event {
  // Called by CA
  function moveBodyType(
    bytes32 bodyTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bool moveChildren,
    bool moveParent
  ) public virtual returns (uint32, bytes32, bytes32) {
    (uint32 scale, bytes32 newEntityId) = super.runEventHandler(
      bodyTypeId,
      newCoord,
      moveChildren,
      moveParent,
      abi.encode(MoveEventData({ oldCoord: oldCoord }))
    );
    bytes32 oldEntityId = getEntityAtCoord(scale, oldCoord);
    return (scale, oldEntityId, newEntityId);
  }

  function preEvent(bytes32 bodyTypeId, VoxelCoord memory coord, bytes memory eventData) internal override {}

  function postEvent(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal override {}

  function runEventHandlerForParent(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal override {}

  function runEventHandlerForIndividualChildren(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes32 childBodyTypeId,
    VoxelCoord memory newChildCoord,
    bytes memory eventData
  ) internal override {
    MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
    bytes32 childVoxelEntity = getEntityAtCoord(scale - 1, moveEventData.oldCoord);
    if (childVoxelEntity != 0) {
      runEventHandler(BodyType.getBodyTypeId(scale - 1, childVoxelEntity), newChildCoord, true, false, eventData);
    }
  }

  function runEventHandlerForChildren(
    bytes32 bodyTypeId,
    BodyTypeRegistryData memory bodyTypeData,
    VoxelCoord memory newCoord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal override {
    // Read the ChildTypes in this CA address
    bytes32[] memory childBodyTypeIds = bodyTypeData.childBodyTypeIds;
    // TODO: Make this general by using cube root
    require(childBodyTypeIds.length == 8, "Invalid length of child voxel type ids");
    // TODO: move this to a library
    MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
    VoxelCoord[] memory eightBlockBodyCoords = calculateChildCoords(2, moveEventData.oldCoord);
    VoxelCoord[] memory newEightBlockVoxelCoords = calculateChildCoords(2, newCoord);
    for (uint8 i = 0; i < 8; i++) {
      runEventHandlerForIndividualChildren(
        bodyTypeId,
        newCoord,
        scale,
        eventBodyEntity,
        childBodyTypeIds[i],
        newEightBlockVoxelCoords[i],
        abi.encode(MoveEventData({ oldCoord: eightBlockBodyCoords[i] }))
      );
    }
  }

  function preRunCA(
    address caAddress,
    bytes32 bodyTypeId,
    VoxelCoord memory newCoord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal override {
    MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
    IWorld(_world()).moveCA(caAddress, scale, bodyTypeId, moveEventData.oldCoord, newCoord, eventBodyEntity);

    bytes32 oldVoxelEntity = getEntityAtCoord(scale, moveEventData.oldCoord);
    require(uint256(oldVoxelEntity) != 0, "No voxel entity at old coord");

    CABodyTypeData memory oldCABodyType = CABodyType.get(IStore(caAddress), _world(), oldVoxelEntity);
    BodyType.set(scale, oldVoxelEntity, oldCABodyType.bodyTypeId, oldCABodyType.bodyVariantId);
  }

  function runCA(address caAddress, uint32 scale, bytes32 eventBodyEntity, bytes memory eventData) internal override {
    MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
    bytes32 oldVoxelEntity = getEntityAtCoord(scale, moveEventData.oldCoord);

    // Need to run 2 interactions because we're moving so two entities are involved
    IWorld(_world()).runCA(caAddress, scale, oldVoxelEntity, bytes4(0));
    IWorld(_world()).runCA(caAddress, scale, eventBodyEntity, bytes4(0));
  }

  function postRunCA(
    address caAddress,
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventBodyEntity,
    bytes memory eventData
  ) internal override {}
}
