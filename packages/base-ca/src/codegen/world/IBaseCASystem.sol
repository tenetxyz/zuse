// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord } from "@tenet-utils/src/Types.sol";

interface IBaseCASystem {
  function defineVoxelTypeDefs() external;

  function isVoxelTypeAllowed(bytes32 voxelTypeId) external pure returns (bool);

  function enterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) external;

  function updateVoxelVariant(bytes32 voxelTypeId, bytes32 entity) external returns (bytes32);

  function exitWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) external;

  function runInteraction(
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) external returns (bytes32[] memory changedEntities);
}
