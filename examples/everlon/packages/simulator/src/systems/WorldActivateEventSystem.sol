// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, EventType } from "@tenet-utils/src/Types.sol";
import { WorldActivateEventSystem as WorldActivateEventProtoSystem } from "@tenet-base-simulator/src/systems/WorldActivateEventSystem.sol";

contract WorldActivateEventSystem is WorldActivateEventProtoSystem {
  function preActivateEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord
  ) public override {
    address worldAddress = _msgSender();
    IWorld(_world()).updateVelocityCache(worldAddress, actingObjectEntityId);
  }

  function onActivateEvent(
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

  function postActivateEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public override {
    IWorld(_world()).resolveCombatMoves();
  }
}
