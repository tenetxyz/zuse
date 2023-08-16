// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { BodyTypeData, VoxelCoord, BaseCreationInWorld } from "@tenet-utils/src/Types.sol";

interface ICreationRegistrySystem {
  function registerCreation(
    string memory name,
    string memory description,
    BodyTypeData[] memory bodyTypes,
    VoxelCoord[] memory voxelCoords,
    BaseCreationInWorld[] memory baseCreationsInWorld
  ) external returns (bytes32, VoxelCoord memory, BodyTypeData[] memory, VoxelCoord[] memory);

  function creationSpawned(bytes32 creationId) external returns (uint256);

  function getVoxelsInCreation(bytes32 creationId) external view returns (VoxelCoord[] memory, BodyTypeData[] memory);
}
