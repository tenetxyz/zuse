// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { RunCASystem as RunCAPrototype } from "@tenet-base-world/src/prototypes/RunCASystem.sol";
import { VoxelCoord } from "@tenet-base-world/src/Types.sol";

contract RunCASystem is RunCAPrototype {
  function enterCA(
    address caAddress,
    uint32 scale,
    bytes32 voxelTypeId,
    bytes4 mindSelector,
    VoxelCoord memory coord,
    bytes32 entity
  ) public override {
    super.enterCA(caAddress, scale, voxelTypeId, mindSelector, coord, entity);
  }

  function moveCA(
    address caAddress,
    uint32 scale,
    bytes32 voxelTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bytes32 newEntity
  ) public override {
    super.moveCA(caAddress, scale, voxelTypeId, oldCoord, newCoord, newEntity);
  }

  function exitCA(
    address caAddress,
    uint32 scale,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes32 entity
  ) public override {
    super.exitCA(caAddress, scale, voxelTypeId, coord, entity);
  }

  function activateCA(address caAddress, uint32 scale, bytes32 entity) public override {
    super.activateCA(caAddress, scale, entity);
  }

  function runCA(address caAddress, uint32 scale, bytes32 entity, bytes4 interactionSelector) public override {
    super.runCA(caAddress, scale, entity, interactionSelector);
  }
}
