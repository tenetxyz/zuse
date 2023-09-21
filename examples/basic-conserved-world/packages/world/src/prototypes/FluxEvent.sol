// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { Event } from "@tenet-base-world/src/prototypes/Event.sol";
import { WorldConfig } from "@tenet-base-world/src/codegen/tables/WorldConfig.sol";
import { Position, PositionTableId } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeTableId, VoxelTypeData } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { VoxelCoord } from "@tenet-base-world/src/Types.sol";
import { VoxelEntity, EntityEventData } from "@tenet-utils/src/Types.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";

abstract contract FluxEvent is Event {
  function flux(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual returns (VoxelEntity memory) {
    VoxelTypeRegistryData memory voxelTypeData = VoxelTypeRegistry.get(IStore(getRegistryAddress()), voxelTypeId);
    uint32 scale = voxelTypeData.scale;
    bytes32 voxelEntityId = getEntityAtCoord(scale, coord);
    require(voxelEntityId != 0, "FluxEvent: no voxel entity at coord");
    (VoxelEntity memory fluxEntity, EntityEventData[] memory entitiesEventData) = runEvent(
      voxelTypeId,
      coord,
      eventData
    );
    processCAEvents(entitiesEventData);
    return fluxEntity;
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

  function getParentEventData(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData,
    bytes32 childVoxelTypeId,
    VoxelCoord memory childCoord
  ) internal override returns (bytes memory) {}

  function getChildEventData(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData,
    uint8 childIdx,
    bytes32 childVoxelTypeId,
    VoxelCoord memory childCoord
  ) internal override returns (bytes memory) {}

  function runEventHandlerForIndividualChildren(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    uint8 childIdx,
    bytes32 childVoxelTypeId,
    VoxelCoord memory childCoord,
    bytes memory eventData
  ) internal virtual override {}

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {}

  function postRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {}

  function runCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override returns (EntityEventData[] memory) {
    return IWorld(_world()).runCA(caAddress, eventVoxelEntity, bytes4(0));
  }
}
