// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord } from "@tenet-utils/src/Types.sol";

interface ICACallerSystem {
  function buildCAWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) external;

  function mineCAWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord) external;

  function moveCAWorld(
    address callerAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord
  ) external returns (bytes32, bytes32);
}
