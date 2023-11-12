// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { Event } from "@tenet-base-world/src/prototypes/Event.sol";
import { VoxelCoord, VoxelEntity, EntityEventData } from "@tenet-utils/src/Types.sol";
import { Position, PositionTableId } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeData } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { Spawn, SpawnData } from "@tenet-base-world/src/codegen/tables/Spawn.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";

abstract contract MineEvent is Event {
  // Called by users
  function mine(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual returns (VoxelEntity memory) {
    return super.runEvent(voxelTypeId, coord, eventData);
  }

  function preEvent(bytes32 voxelTypeId, VoxelCoord memory coord, bytes memory eventData) internal virtual override {
    IWorld(_world()).approveMine(_msgSender(), voxelTypeId, coord, eventData);
  }

  function postEvent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData,
    EntityEventData[] memory entitiesEventData
  ) internal virtual override {
    super.postEvent(voxelTypeId, coord, eventVoxelEntity, eventData, entitiesEventData);
    bytes32 useParentEntity = IWorld(_world()).calculateParentEntity(eventVoxelEntity);
    uint32 useParentScale = eventVoxelEntity.scale + 1;
    while (useParentEntity != 0) {
      bytes32 parentVoxelTypeId = VoxelType.getVoxelTypeId(useParentScale, useParentEntity);
      VoxelCoord memory parentCoord = positionDataToVoxelCoord(Position.get(useParentScale, useParentEntity));
      (VoxelEntity memory minedParentEntity, ) = runEventHandler(
        parentVoxelTypeId,
        parentCoord,
        false,
        false,
        eventData
      );
      useParentEntity = IWorld(_world()).calculateParentEntity(minedParentEntity);
    }
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

  function getChildEventData(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData,
    uint8 childIdx,
    bytes32 childVoxelTypeId,
    VoxelCoord memory childCoord
  ) internal override returns (bytes memory) {
    // TODO: Update when using event data. Child event data should be different from parent event data
    return eventData;
  }

  function runEventHandlerForIndividualChildren(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    uint8 childIdx,
    bytes32 childVoxelTypeId,
    VoxelCoord memory childCoord,
    bytes memory eventData
  ) internal virtual override {
    uint32 scale = eventVoxelEntity.scale;
    bytes32 childVoxelEntity = getEntityAtCoord(scale - 1, childCoord);
    if (childVoxelEntity != 0) {
      runEventHandler(
        VoxelType.getVoxelTypeId(scale - 1, childVoxelEntity),
        childCoord,
        true,
        false,
        getChildEventData(voxelTypeId, coord, eventVoxelEntity, eventData, childIdx, childVoxelTypeId, childCoord)
      );
    }
  }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override returns (VoxelEntity memory) {
    // Enter World
    IWorld(_world()).exitCA(caAddress, eventVoxelEntity, voxelTypeId, coord);
    return super.preRunCA(caAddress, voxelTypeId, coord, eventVoxelEntity, eventData);
  }

  function runCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override returns (EntityEventData[] memory) {
    return IWorld(_world()).runCA(caAddress, eventVoxelEntity, bytes4(0));
  }

  function postRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {
  }
}
