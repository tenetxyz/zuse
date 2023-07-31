// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { VoxelVariantsRegistryData } from "./../Tables.sol";

interface IVoxelRegistrySystem {
  function registerVoxelType(
    string memory voxelTypeName,
    bytes32 voxelTypeId,
    bytes32[] memory childVoxelTypeIds,
    bytes32[] memory schemaVoxelTypeIds,
    bytes32 previewVoxelVariantId
  ) external;

  function registerVoxelVariant(bytes32 voxelVariantId, VoxelVariantsRegistryData memory voxelVariant) external;
}
