// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, EventType, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { WorldBuildEventSystem as WorldBuildEventProtoSystem } from "@tenet-base-simulator/src/systems/WorldBuildEventSystem.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";

contract WorldBuildEventSystem is WorldBuildEventProtoSystem {
  function preBuildEvent(bytes32 actingObjectEntityId, bytes32 objectTypeId, VoxelCoord memory coord) public override {}

  function onBuildEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId,
    ObjectProperties memory objectProperties,
    bool isNewEntity
  ) public override {
    address world = _msgSender();
    Mass.set(world, objectEntityId, objectProperties.mass);
  }

  function postBuildEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public override {}
}
