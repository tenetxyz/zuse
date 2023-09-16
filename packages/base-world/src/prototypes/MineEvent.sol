// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { Event } from "@tenet-base-world/src/prototypes/Event.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { Position, PositionTableId } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeData } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { Spawn, SpawnData } from "@tenet-base-world/src/codegen/tables/Spawn.sol";
import { OfSpawn } from "@tenet-base-world/src/codegen/tables/OfSpawn.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";

abstract contract MineEvent is Event {
  // Called by users
  function mine(bytes32 voxelTypeId, VoxelCoord memory coord, bytes memory eventData) internal virtual returns (VoxelEntity memory) {
    super.runEvent(voxelTypeId, coord, eventData);
  }

  // Called by CA
  function mineVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool mineChildren,
    bool mineParent,
    bytes memory eventData
  ) internal virtual returns (VoxelEntity memory);

  function preEvent(bytes32 voxelTypeId, VoxelCoord memory coord, bytes memory eventData) internal virtual override {
    IWorld(_world()).approveMine(tx.origin, voxelTypeId, coord, eventData);
  }

  function postEvent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {
    bytes32 useParentEntity = IWorld(_world()).calculateParentEntity(eventVoxelEntity);
    uint32 useParentScale = eventVoxelEntity.scale + 1;
    while (useParentEntity != 0) {
      bytes32 parentVoxelTypeId = VoxelType.getVoxelTypeId(useParentScale, useParentEntity);
      VoxelCoord memory parentCoord = positionDataToVoxelCoord(Position.get(useParentScale, useParentEntity));
      VoxelEntity memory minedParentEntity = callEventHandler(
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
      runEventHandler(VoxelType.getVoxelTypeId(scale - 1, childVoxelEntity), childCoord, true, false,
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
  ) internal virtual override {
    // Enter World
    IWorld(_world()).exitCA(caAddress, eventVoxelEntity, voxelTypeId, coord);
  }

  function runCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {
    IWorld(_world()).runCA(caAddress, eventVoxelEntity, bytes4(0));
  }

  function postRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {
    tryRemoveVoxelFromSpawn(eventVoxelEntity);
  }

  function tryRemoveVoxelFromSpawn(VoxelEntity memory entity) internal {
    uint32 scale = entity.scale;
    bytes32 entityId = entity.entityId;
    bytes32 spawnId = OfSpawn.get(scale, entityId);
    if (spawnId == 0) {
      return;
    }

    OfSpawn.deleteRecord(scale, entityId);
    SpawnData memory spawn = Spawn.get(spawnId);

    // should we check to see if the entity is in the array before trying to remove it?
    // I think it's ok to assume it's there, since this is the only way to remove a voxel from a spawn
    VoxelEntity[] memory existingVoxels = abi.decode(spawn.voxels, (VoxelEntity[]));
    VoxelEntity[] memory newVoxels = new VoxelEntity[](existingVoxels.length - 1);
    uint index = 0;

    // Copy elements from the original array to the updated array, excluding the entity
    for (uint i = 0; i < existingVoxels.length; i++) {
      if (existingVoxels[i].scale != scale || existingVoxels[i].entityId != entityId) {
        newVoxels[index] = existingVoxels[i];
        index++;
      }
    }

    if (newVoxels.length == 0) {
      // no more voxels of this spawn are in the world, so delete it
      Spawn.deleteRecord(spawnId);
    } else {
      // This spawn is still in the world, but it has been modified (since a voxel was removed)
      Spawn.setVoxels(spawnId, abi.encode(newVoxels));
      Spawn.setIsModified(spawnId, true);
    }
  }
}
