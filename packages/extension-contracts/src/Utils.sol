// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { VoxelCoord } from "@tenet-contracts/src/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Signal, SignalSource, Powered, InvertedSignal } from "@tenet-extension-contracts/src/codegen/Tables.sol";
import { CLEAR_COORD_SIG, BUILD_SIG } from "@tenet-contracts/src/constants.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { REGISTER_EXTENSION_SIG, REGISTER_VOXEL_TYPE_SIG, REGISTER_VOXEL_VARIANT_SIG } from "@tenet-contracts/src/constants.sol";
import { VoxelVariantsData } from "@tenet-contracts/src/codegen/tables/VoxelVariants.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { safeCall } from "@tenet-contracts/src/Utils.sol";

function registerExtension(address world, string memory extensionName, bytes4 eventHandlerSelector) {
  safeCall(
    world,
    abi.encodeWithSignature(REGISTER_EXTENSION_SIG, eventHandlerSelector, extensionName),
    string(abi.encodePacked("registerExtension ", extensionName))
  );
}

function registerVoxelType(
  address world,
  string memory voxelTypeName,
  bytes32 voxelTypeId,
  bytes16 previewVoxelVariantNamespace,
  bytes32 previewVoxelVariantId,
  bytes4 variantSelector,
  bytes4 enterWorldSelector,
  bytes4 exitWorldSelector
) {
  safeCall(
    world,
    abi.encodeWithSignature(
      REGISTER_VOXEL_TYPE_SIG,
      voxelTypeName,
      voxelTypeId,
      previewVoxelVariantNamespace,
      previewVoxelVariantId,
      variantSelector,
      enterWorldSelector,
      exitWorldSelector
    ),
    string(abi.encodePacked("registerVoxelType ", voxelTypeName))
  );
}

function registerVoxelVariant(address world, bytes32 voxelVariantId, VoxelVariantsData memory voxelVariantData) {
  safeCall(
    world,
    abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, voxelVariantId, voxelVariantData),
    string(abi.encodePacked("registerVoxelVariant ", voxelVariantId))
  );
}

function entityIsSignal(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
  return Signal.get(callerNamespace, entity).hasValue;
}

function entityIsSignalSource(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
  return SignalSource.get(callerNamespace, entity).hasValue;
}

function entityIsPowered(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
  return Powered.get(callerNamespace, entity).hasValue;
}

function entityIsInvertedSignal(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
  return InvertedSignal.get(callerNamespace, entity).hasValue;
}

function clearCoord(address worldAddress, VoxelCoord memory coord) {
  safeCall(worldAddress, abi.encodeWithSignature(CLEAR_COORD_SIG, coord), "clearCoord");
}

function build(address worldAddress, VoxelCoord memory coord, bytes32 entity) {
  safeCall(worldAddress, abi.encodeWithSignature(BUILD_SIG, entity, coord), "build");
}
