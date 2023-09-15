// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { VoxelEntity } from "@tenet-utils/src/Types.sol";

interface IExternalCASystem {
  function getVoxelTypeId(VoxelEntity memory entity) external view returns (bytes32);

  function calculateNeighbourEntities(VoxelEntity memory centerEntity) external view returns (bytes32[] memory);

  function calculateChildEntities(VoxelEntity memory entity) external view returns (bytes32[] memory);

  function calculateParentEntity(VoxelEntity memory entity) external view returns (bytes32);
}