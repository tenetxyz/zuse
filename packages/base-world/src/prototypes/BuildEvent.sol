// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { Event } from "@tenet-base-world/src/prototypes/Event.sol";

import { VoxelCoord, EntityActionData } from "@tenet-utils/src/Types.sol";

abstract contract BuildEvent is Event {
  function build(
    bytes32 actingObjectEntityId,
    bytes32 buildObjectTypeId,
    VoxelCoord memory buildCoord,
    bytes memory eventData
  ) internal virtual returns (bytes32) {
    return super.runEvent(actingObjectEntityId, buildObjectTypeId, buildCoord, eventData);
  }

  function preEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual override {
    IWorld(_world()).approveBuild(_msgSender(), actingObjectEntityId, objectTypeId, coord, eventData);
  }

  function preRunObject(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes32 objectEntityId,
    bytes memory eventData
  ) internal virtual override returns (bytes32) {
    return eventEntityId;
  }

  function postRunObject(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes32 objectEntityId,
    bytes memory eventData
  ) internal virtual override {}

  function runObject(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 eventEntityId,
    bytes32 objectEntityId,
    bytes memory eventData
  ) internal virtual override returns (EntityActionData[] memory) {
    return IWorld(_world()).runObjectEventHandler(eventEntityId);
  }
}
