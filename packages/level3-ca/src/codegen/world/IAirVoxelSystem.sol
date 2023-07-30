// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord } from "@tenet-utils/src/Types.sol";

interface IAirVoxelSystem {
  function registerVoxelAir() external;

  function enterWorldAir(address callerAddress, VoxelCoord memory coord, bytes32 entity) external;

  function exitWorldAir(address callerAddress, VoxelCoord memory coord, bytes32 entity) external;

  function variantSelectorAir(address callerAddress, bytes32 entity) external view returns (bytes32);
}
