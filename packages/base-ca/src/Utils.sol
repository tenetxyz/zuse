// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { REGISTRY_WORLD } from "./Constants.sol";
import { REGISTER_VOXEL_TYPE_SIG, REGISTER_VOXEL_VARIANT_SIG } from "@tenet-registry/src/Constants.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

function registerVoxelVariant(bytes32 voxelVariantId, VoxelVariantsRegistryData memory voxelVariantData) {
  safeCall(
    REGISTRY_WORLD,
    abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, voxelVariantId, voxelVariantData),
    "registerVoxelVariant"
  );
}

function registerVoxelType(
  string memory name,
  bytes32 voxelTypeId,
  bytes32[] memory childVoxelTypeIds,
  bytes32 voxelVariantId
) {
  safeCall(
    REGISTRY_WORLD,
    abi.encodeWithSignature(REGISTER_VOXEL_TYPE_SIG, name, voxelTypeId, childVoxelTypeIds, voxelVariantId),
    "registerVoxelType"
  );
}
