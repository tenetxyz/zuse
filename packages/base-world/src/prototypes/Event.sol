// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { EventType } from "@tenet-base-world/src/Types.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { WorldConfig, WorldConfigTableId } from "@tenet-base-world/src/codegen/tables/WorldConfig.sol";
import { VoxelType, VoxelTypeData } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";

abstract contract Event is System {
  function getRegistryAddress() internal pure virtual returns (address);

  function preEvent(bytes32 voxelTypeId, VoxelCoord memory coord, bytes memory eventData) internal virtual;

  function postEvent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes memory eventData
  ) internal virtual;

  function callEventHandler(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent,
    bytes memory eventData
  ) internal virtual returns (uint32, bytes32);

  function runEvent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual returns (uint32, bytes32) {
    preEvent(voxelTypeId, coord, eventData);

    (uint32 scale, bytes32 eventVoxelEntity) = callEventHandler(voxelTypeId, coord, true, true, eventData);

    postEvent(voxelTypeId, coord, scale, eventVoxelEntity, eventData);

    return (scale, eventVoxelEntity);
  }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes memory eventData
  ) internal virtual;

  function postRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes memory eventData
  ) internal virtual;

  function runCA(address caAddress, uint32 scale, bytes32 eventVoxelEntity, bytes memory eventData) internal virtual;

  function runEventHandlerForParent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes memory eventData
  ) internal virtual;

  function runEventHandlerForChildren(
    bytes32 voxelTypeId,
    VoxelTypeRegistryData memory voxelTypeData,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes memory eventData
  ) internal virtual {
    // Read the ChildTypes in this CA address
    bytes32[] memory childVoxelTypeIds = voxelTypeData.childVoxelTypeIds;
    // TODO: Make this general by using cube root
    require(childVoxelTypeIds.length == 8, "Invalid length of child voxel type ids");
    // TODO: move this to a library
    VoxelCoord[] memory eightBlockVoxelCoords = calculateChildCoords(2, coord);
    for (uint8 i = 0; i < 8; i++) {
      runEventHandlerForIndividualChildren(
        voxelTypeId,
        coord,
        scale,
        eventVoxelEntity,
        childVoxelTypeIds[i],
        eightBlockVoxelCoords[i],
        eventData
      );
    }
  }

  function runEventHandlerForIndividualChildren(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes32 childVoxelTypeId,
    VoxelCoord memory childCoord,
    bytes memory eventData
  ) internal virtual;

  // Called by CA
  function runEventHandler(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent,
    bytes memory eventData
  ) internal virtual returns (uint32, bytes32) {
    require(
      _msgSender() == _world() || IWorld(_world()).isCAAllowed(_msgSender()),
      "Not allowed to run event handler. Must be world or CA"
    );
    (uint32 scale, bytes32 eventVoxelEntity) = runEventHandlerHelper(voxelTypeId, coord, runEventOnChildren, eventData);

    if (runEventOnParent) {
      runEventHandlerForParent(voxelTypeId, coord, scale, eventVoxelEntity, eventData);
    }

    return (scale, eventVoxelEntity);
  }

  function runEventHandlerHelper(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bytes memory eventData
  ) internal virtual returns (uint32, bytes32) {
    require(IWorld(_world()).isVoxelTypeAllowed(voxelTypeId), "Voxel type not allowed in this world");
    VoxelTypeRegistryData memory voxelTypeData = VoxelTypeRegistry.get(IStore(getRegistryAddress()), voxelTypeId);
    address caAddress = WorldConfig.get(voxelTypeId);

    uint32 scale = voxelTypeData.scale;

    bytes32 eventVoxelEntity = getEntityAtCoord(scale, coord);
    if (uint256(eventVoxelEntity) == 0) {
      eventVoxelEntity = getUniqueEntity();
      Position.set(scale, eventVoxelEntity, coord.x, coord.y, coord.z);
    }

    if (runEventOnChildren && scale > 1) {
      runEventHandlerForChildren(voxelTypeId, voxelTypeData, coord, scale, eventVoxelEntity, eventData);
    }

    preRunCA(caAddress, voxelTypeId, coord, scale, eventVoxelEntity, eventData);

    // Set initial voxel type
    CAVoxelTypeData memory entityCAVoxelType = CAVoxelType.get(IStore(caAddress), _world(), eventVoxelEntity);
    VoxelType.set(scale, eventVoxelEntity, entityCAVoxelType.voxelTypeId, entityCAVoxelType.voxelVariantId);

    runCA(caAddress, scale, eventVoxelEntity, eventData);

    postRunCA(caAddress, voxelTypeId, coord, scale, eventVoxelEntity, eventData);

    return (scale, eventVoxelEntity);
  }
}
