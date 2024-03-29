// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord } from "@tenet-utils/src/Types.sol";

interface IWorldActivateEventSystem {
  function preActivateEvent(bytes32 actingObjectEntityId, bytes32 objectTypeId, VoxelCoord memory coord) external;

  function onActivateEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) external;

  function postActivateEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) external;
}
