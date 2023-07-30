// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord } from "@tenet-utils/src/Types.sol";

interface IElectronVoxelSystem {
  function registerVoxelElectron() external;

  function enterWorldElectron(address callerAddress, VoxelCoord memory coord, bytes32 entity) external;

  function exitWorldElectron(address callerAddress, VoxelCoord memory coord, bytes32 entity) external;

  function variantSelectorElectron(address callerAddress, bytes32 entity) external view returns (bytes32);
}