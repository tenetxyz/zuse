// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { EventType } from "@tenet-contracts/src/Types.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { WorldConfig, OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData, OfSpawn, Spawn, SpawnData } from "@tenet-contracts/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "@tenet-contracts/src/Utils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";

abstract contract Event is System {
  function preEvent(bytes32 voxelTypeId, VoxelCoord memory coord) internal virtual;

  function postEvent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity
  ) internal virtual;

  function callEventHandler(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent
  ) internal virtual returns (uint32, bytes32);

  function runEvent(bytes32 voxelTypeId, VoxelCoord memory coord) internal virtual returns (uint32, bytes32) {
    preEvent(voxelTypeId, coord);

    (uint32 scale, bytes32 eventVoxelEntity) = callEventHandler(voxelTypeId, coord, true, true);

    postEvent(voxelTypeId, coord, scale, eventVoxelEntity);

    return (scale, eventVoxelEntity);
  }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity
  ) internal virtual;

  function postRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity
  ) internal virtual;

  function runEventHandlerForParent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity
  ) internal virtual;

  function runEventHandlerForChildren(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes32 childVoxelTypeId,
    VoxelCoord memory childCoord
  ) internal virtual;

  // Called by CA
  function runEventHandler(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent
  ) internal virtual returns (uint32, bytes32) {
    require(
      _msgSender() == _world() || IWorld(_world()).isCAAllowed(_msgSender()),
      "Not allowed to run event handler. Must be world or CA"
    );
    (uint32 scale, bytes32 eventVoxelEntity) = runEventHandlerHelper(voxelTypeId, coord, runEventOnChildren);

    if (runEventOnParent) {
      runEventHandlerForParent(voxelTypeId, coord, scale, eventVoxelEntity);
    }

    return (scale, eventVoxelEntity);
  }

  function runEventHandlerHelper(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren
  ) internal virtual returns (uint32, bytes32) {
    require(IWorld(_world()).isVoxelTypeAllowed(voxelTypeId), "Voxel type not allowed in this world");
    VoxelTypeRegistryData memory voxelTypeData = VoxelTypeRegistry.get(IStore(REGISTRY_ADDRESS), voxelTypeId);
    address caAddress = WorldConfig.get(voxelTypeId);

    uint32 scale = voxelTypeData.scale;

    bytes32 eventVoxelEntity = getEntityAtCoord(scale, coord);
    if (uint256(eventVoxelEntity) == 0) {
      eventVoxelEntity = getUniqueEntity();
      Position.set(scale, eventVoxelEntity, coord.x, coord.y, coord.z);
    }

    if (runEventOnChildren && scale > 1) {
      // Read the ChildTypes in this CA address
      bytes32[] memory childVoxelTypeIds = voxelTypeData.childVoxelTypeIds;
      // TODO: Make this general by using cube root
      require(childVoxelTypeIds.length == 8, "Invalid length of child voxel type ids");
      // TODO: move this to a library
      VoxelCoord[] memory eightBlockVoxelCoords = calculateChildCoords(2, coord);
      for (uint8 i = 0; i < 8; i++) {
        runEventHandlerForChildren(
          voxelTypeId,
          coord,
          scale,
          eventVoxelEntity,
          childVoxelTypeIds[i],
          eightBlockVoxelCoords[i]
        );
      }
    }

    preRunCA(caAddress, voxelTypeId, coord, scale, eventVoxelEntity);

    // Set initial voxel type
    CAVoxelTypeData memory entityCAVoxelType = CAVoxelType.get(IStore(caAddress), _world(), eventVoxelEntity);
    VoxelType.set(scale, eventVoxelEntity, entityCAVoxelType.voxelTypeId, entityCAVoxelType.voxelVariantId);

    IWorld(_world()).runCA(caAddress, scale, eventVoxelEntity);

    postRunCA(caAddress, voxelTypeId, coord, scale, eventVoxelEntity);

    return (scale, eventVoxelEntity);
  }
}
