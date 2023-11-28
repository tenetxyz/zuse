// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, EventType } from "@tenet-utils/src/Types.sol";
import { WorldMineEventSystem as WorldMineEventProtoSystem } from "@tenet-base-simulator/src/systems/WorldMineEventSystem.sol";

contract WorldMineEventSystem is WorldMineEventProtoSystem {
  function preMineEvent(bytes32 actingObjectEntityId, bytes32 objectTypeId, VoxelCoord memory coord) public override {
    address worldAddress = _msgSender();
    IWorld(_world()).updateVelocityCache(worldAddress, actingObjectEntityId);
  }

  function onMineEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public override {
    address worldAddress = _msgSender();
    if (objectEntityId != actingObjectEntityId) {
      IWorld(_world()).updateVelocityCache(worldAddress, objectEntityId);
    }
  }

  function postMineEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public override {}
}
