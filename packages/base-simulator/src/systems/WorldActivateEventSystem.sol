// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, EventType } from "@tenet-utils/src/Types.sol";

abstract contract WorldActivateEventSystem is System {
  function preActivateEvent(bytes32 actingObjectEntityId, bytes32 objectTypeId, VoxelCoord memory coord) public virtual;

  function onActivateEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public virtual;

  function postActivateEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public virtual;
}
