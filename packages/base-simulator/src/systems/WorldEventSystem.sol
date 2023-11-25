// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, EventType } from "@tenet-utils/src/Types.sol";

abstract contract WorldEventSystem is System {
  function preEvent(
    EventType eventType,
    bytes32 actingObjectEntityId,
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public virtual;

  function onEvent(
    EventType eventType,
    bytes32 actingObjectEntityId,
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public virtual;

  function postEvent(
    EventType eventType,
    bytes32 actingObjectEntityId,
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) public virtual;
}
