// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { REGISTER_VOXEL_TYPE_SIG, REGISTER_VOXEL_VARIANT_SIG, REGISTER_CREATION_SIG, GET_VOXELS_IN_CREATION_SIG, CREATION_SPAWNED_SIG, VOXEL_SPAWNED_SIG } from "@tenet-registry/src/Constants.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { VoxelCoord, BaseCreationInWorld, VoxelTypeData } from "@tenet-utils/src/Types.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

function registerVoxelVariant(
  address registryAddress,
  bytes32 voxelVariantId,
  VoxelVariantsRegistryData memory voxelVariantData
) returns (bytes memory) {
  return
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
  bytes32 baseVoxelTypeId,
  bytes32[] memory childVoxelTypeIds,
  bytes32[] memory schemaVoxelTypeIds,
  bytes32 voxelVariantId
) returns (bytes memory) {
  return
    safeCall(
      registryAddress,
      abi.encodeWithSignature(
        REGISTER_VOXEL_TYPE_SIG,
        name,
        voxelTypeId,
        baseVoxelTypeId,
        childVoxelTypeIds,
        schemaVoxelTypeIds,
        voxelVariantId
      ),
      "registerVoxelType"
    );
}

function registerCreation(
  address registryAddress,
  string memory name,
  string memory description,
  VoxelTypeData[] memory voxelTypes,
  VoxelCoord[] memory voxelCoords,
  BaseCreationInWorld[] memory baseCreationsInWorld
) returns (bytes32, VoxelCoord memory, VoxelTypeData[] memory, VoxelCoord[] memory) {
  bytes memory result = safeCall(
    registryAddress,
    abi.encodeWithSignature(REGISTER_CREATION_SIG, name, description, voxelTypes, voxelCoords, baseCreationsInWorld),
    "registerCreation"
  );
  return abi.decode(result, (bytes32, VoxelCoord, VoxelTypeData[], VoxelCoord[]));
}

function getVoxelsInCreation(
  address registryAddress,
  bytes32 creationId
) returns (VoxelCoord[] memory, VoxelTypeData[] memory) {
  bytes memory result = safeCall(
    registryAddress,
    abi.encodeWithSignature(GET_VOXELS_IN_CREATION_SIG, creationId),
    "getVoxelsInCreation"
  );
  return abi.decode(result, (VoxelCoord[], VoxelTypeData[]));
}

function creationSpawned(address registryAddress, bytes32 creationId) returns (uint256) {
  bytes memory result = safeCall(
    registryAddress,
    abi.encodeWithSignature(CREATION_SPAWNED_SIG, creationId),
    "creationSpawned"
  );
  return abi.decode(result, (uint256));
}

function voxelSpawned(address registryAddress, bytes32 voxelTypeId) returns (uint256) {
  bytes memory result = safeCall(
    registryAddress,
    abi.encodeWithSignature(VOXEL_SPAWNED_SIG, voxelTypeId),
    "voxelSpawned"
  );
  return abi.decode(result, (uint256));
}
