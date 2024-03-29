// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

interface IWorldBuildEventSystem {
  function preBuildEvent(bytes32 actingObjectEntityId, bytes32 objectTypeId, VoxelCoord memory coord) external;

  function onBuildEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId,
    ObjectProperties memory objectProperties,
    bool isNewEntity
  ) external;

  function postBuildEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) external;
}
