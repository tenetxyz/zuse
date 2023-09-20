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
import { VoxelCoord, ActivateEventData } from "@tenet-base-world/src/Types.sol";
import { VoxelEntity, EntityEventData } from "@tenet-utils/src/Types.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "@tenet-base-world/src/Utils.sol";

abstract contract ActivateEvent is Event {
  function activate(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual returns (VoxelEntity memory) {
    VoxelTypeRegistryData memory voxelTypeData = VoxelTypeRegistry.get(IStore(getRegistryAddress()), voxelTypeId);
    uint32 scale = voxelTypeData.scale;
    bytes32 voxelEntityId = getEntityAtCoord(scale, coord);
    require(voxelEntityId != 0, "ActivateEvent: no voxel entity at coord");
    (VoxelEntity memory activateEntity, EntityEventData[] memory entitiesEventData) = runEvent(
      voxelTypeId,
      coord,
      eventData
    );
    return activateEntity;
  }

  function preEvent(bytes32 voxelTypeId, VoxelCoord memory coord, bytes memory eventData) internal virtual override {
    IWorld(_world()).approveActivate(_msgSender(), voxelTypeId, coord, eventData);
  }

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
  ) internal override returns (bytes memory) {
    ActivateEventData memory parentActivateEventData = abi.decode(eventData, (ActivateEventData));
    parentActivateEventData.interactionSelector = bytes4(0);
    return abi.encode(parentActivateEventData);
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
    ActivateEventData memory childActivateEventData = abi.decode(eventData, (ActivateEventData));
    childActivateEventData.interactionSelector = bytes4(0);
    return abi.encode(childActivateEventData);
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
    if (childVoxelTypeId != 0) {
      runEventHandler(
        childVoxelTypeId,
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
  ) internal virtual override {}

  function postRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {
    IWorld(_world()).activateCA(caAddress, eventVoxelEntity);
  }

  function runCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override returns (EntityEventData[] memory) {
    ActivateEventData memory activateEventData = abi.decode(eventData, (ActivateEventData));
    return IWorld(_world()).runCA(caAddress, eventVoxelEntity, activateEventData.interactionSelector);
  }
}
