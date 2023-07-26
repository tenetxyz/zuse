// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { REGISTER_VOXEL_TYPE_SIG, REGISTER_VOXEL_VARIANT_SIG } from "./Constants.sol";
import { VoxelVariantsRegistryData } from "./codegen/tables/VoxelVariantsRegistry.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

function registerVoxelVariant(
  address registryAddress,
  bytes32 voxelVariantId,
  VoxelVariantsRegistryData memory voxelVariantData
) {
  safeCall(
    registryAddress,
    abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, voxelVariantId, voxelVariantData),
    "registerVoxelVariant"
  );
}

function registerVoxelType(
  address registryAddress,
  string memory name,
  bytes32 voxelTypeId,
  bytes32[] memory childVoxelTypeIds,
  bytes32 voxelVariantId
) {
  safeCall(
    registryAddress,
    abi.encodeWithSignature(REGISTER_VOXEL_TYPE_SIG, name, voxelTypeId, childVoxelTypeIds, voxelVariantId),
    "registerVoxelType"
  );
}
