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
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual;

  function runEvent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual returns (VoxelEntity memory) {
    preEvent(voxelTypeId, coord, eventData);

    VoxelEntity memory eventVoxelEntity = runEventHandler(voxelTypeId, coord, true, true, eventData);

    postEvent(voxelTypeId, coord, eventVoxelEntity, eventData);

    return eventVoxelEntity;
  }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual;

  function postRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual;

  function runCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual;

  function runEventHandlerForParent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual;

  function getChildEventData(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData,
    uint8 childIdx,
    bytes32 childVoxelTypeId,
    VoxelCoord memory childCoord
  ) internal virtual returns (bytes memory);

  function getParentEventData(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData,
    bytes32 parentVoxelTypeId,
    VoxelCoord memory parentCoord
  ) internal virtual returns (bytes memory);

  function runEventHandlerForChildren(
    bytes32 voxelTypeId,
    VoxelTypeRegistryData memory voxelTypeData,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
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
        eventVoxelEntity,
        i,
        childVoxelTypeIds[i],
        eightBlockVoxelCoords[i],
        eventData
      );
    }
  }

  function runEventHandlerForIndividualChildren(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    uint8 childIdx,
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
  ) internal virtual returns (VoxelEntity memory) {
    VoxelEntity memory eventVoxelEntity = runEventHandlerHelper(voxelTypeId, coord, runEventOnChildren, eventData);

    if (runEventOnParent) {
      runEventHandlerForParent(voxelTypeId, coord, eventVoxelEntity, eventData);
    }

    return eventVoxelEntity;
  }

  function runEventHandlerHelper(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bytes memory eventData
  ) internal virtual returns (VoxelEntity memory) {
    require(IWorld(_world()).isVoxelTypeAllowed(voxelTypeId), "Voxel type not allowed in this world");
    VoxelTypeRegistryData memory voxelTypeData = VoxelTypeRegistry.get(IStore(getRegistryAddress()), voxelTypeId);
    address caAddress = WorldConfig.get(voxelTypeId);

    uint32 scale = voxelTypeData.scale;

    bytes32 voxelEntityId = getEntityAtCoord(scale, coord);
    if (uint256(voxelEntityId) == 0) {
      voxelEntityId = getUniqueEntity();
      Position.set(scale, voxelEntityId, coord.x, coord.y, coord.z);
    }
    VoxelEntity memory eventVoxelEntity = VoxelEntity({
      scale: scale,
      entityId: voxelEntityId
    });

    if (runEventOnChildren && scale > 1) {
      runEventHandlerForChildren(voxelTypeId, voxelTypeData, coord, eventVoxelEntity, eventData);
    }

    preRunCA(caAddress, voxelTypeId, coord, eventVoxelEntity, eventData);

    // Set initial voxel type
    CAVoxelTypeData memory entityCAVoxelType = CAVoxelType.get(IStore(caAddress), _world(), voxelEntityId);
    VoxelType.set(scale, voxelEntityId, entityCAVoxelType.voxelTypeId, entityCAVoxelType.voxelVariantId);

    runCA(caAddress, voxelTypeId, coord, eventVoxelEntity, eventData);

    postRunCA(caAddress, voxelTypeId, coord, eventVoxelEntity, eventData);

    return eventVoxelEntity;
  }
}
