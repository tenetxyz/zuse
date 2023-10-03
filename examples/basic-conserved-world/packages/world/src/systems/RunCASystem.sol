// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { RunCASystem as RunCAPrototype } from "@tenet-base-world/src/prototypes/RunCASystem.sol";
import { VoxelCoord, VoxelEntity, EntityEventData } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { updateVelocityCache } from "@tenet-simulator/src/CallUtils.sol";

contract RunCASystem is RunCAPrototype {
  function enterCA(
    address caAddress,
    VoxelEntity memory entity,
    bytes32 voxelTypeId,
    bytes4 mindSelector,
    VoxelCoord memory coord
  ) public override {
    super.enterCA(caAddress, entity, voxelTypeId, mindSelector, coord);
  }

  function moveCA(
    address caAddress,
    VoxelEntity memory newEntity,
    bytes32 voxelTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord
  ) public override {
    super.moveCA(caAddress, newEntity, voxelTypeId, oldCoord, newCoord);
  }

  function exitCA(
    address caAddress,
    VoxelEntity memory entity,
    bytes32 voxelTypeId,
    VoxelCoord memory coord
  ) public override {
    super.exitCA(caAddress, entity, voxelTypeId, coord);
  }

  function activateCA(address caAddress, VoxelEntity memory entity) public override {
    super.activateCA(caAddress, entity);
  }

  function beforeRunInteraction(VoxelEntity memory entity) internal override {
    updateVelocityCache(SIMULATOR_ADDRESS, entity);
  }

  function runCA(
    address caAddress,
    VoxelEntity memory entity,
    bytes4 interactionSelector
  ) public override returns (EntityEventData[] memory) {
    return super.runCA(caAddress, entity, interactionSelector);
  }
}
