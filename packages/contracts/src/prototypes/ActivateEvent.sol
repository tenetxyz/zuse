// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { Event } from "./Event.sol";
import { WorldConfig, Position, PositionTableId, VoxelType, VoxelTypeTableId, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelCoord } from "../Types.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "../Utils.sol";

abstract contract ActivateEvent is Event {
  // Called by users
  function activate(bytes32 voxelTypeId, VoxelCoord memory coord) public virtual returns (uint32, bytes32) {
    VoxelTypeRegistryData memory voxelTypeData = VoxelTypeRegistry.get(IStore(REGISTRY_ADDRESS), voxelTypeId);
    uint32 scale = voxelTypeData.scale;
    bytes32 eventVoxelEntity = getEntityAtCoord(scale, coord);
    require(eventVoxelEntity != 0, "ActivateEvent: no voxel entity at coord");
    return runEvent(voxelTypeId, coord, abi.encode(0));
  }

  // Called by CA
  function activateVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool activateChildren,
    bool activateParent,
    bytes memory eventData
  ) public virtual returns (uint32, bytes32);

  function preEvent(bytes32 voxelTypeId, VoxelCoord memory coord, bytes memory eventData) internal override {
    IWorld(_world()).approveActivate(tx.origin, voxelTypeId, coord);
  }

  function postEvent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes memory eventData
  ) internal override {}

  function runEventHandlerForParent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes memory eventData
  ) internal override {}

  function runEventHandlerForIndividualChildren(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes32 childVoxelTypeId,
    VoxelCoord memory childCoord,
    bytes memory eventData
  ) internal override {
    if (childVoxelTypeId != 0) {
      runEventHandler(childVoxelTypeId, childCoord, true, false, eventData);
    }
  }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes memory eventData
  ) internal override {}

  function postRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes memory eventData
  ) internal override {
    IWorld(_world()).activateCA(caAddress, scale, eventVoxelEntity);
  }
}
