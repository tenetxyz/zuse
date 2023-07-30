// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord } from "@tenet-utils/src/Types.sol";

interface ICASystem {
  function terrainGen(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) external;
}
