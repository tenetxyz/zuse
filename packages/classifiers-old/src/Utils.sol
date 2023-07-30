// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { VoxelCoord } from "@tenet-contracts/src/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Signal, SignalData, SignalSource, Powered, InvertedSignal, Temperature, Generator, PowerWire, Storage, Consumer, PowerSignal } from "@tenet-extension-contracts/src/codegen/Tables.sol";
import { CLEAR_COORD_SIG, BUILD_SIG, GIFT_VOXEL_SIG } from "@tenet-contracts/src/constants.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { REGISTER_EXTENSION_SIG, REGISTER_VOXEL_TYPE_SIG, REGISTER_VOXEL_VARIANT_SIG, RM_ALL_OWNED_VOXELS_SIG } from "@tenet-contracts/src/constants.sol";
import { VoxelVariantsData } from "@tenet-contracts/src/codegen/tables/VoxelVariants.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { safeCall } from "@tenet-contracts/src/Utils.sol";

function entityIsActiveSignal(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
  SignalData memory signalData = Signal.get(callerNamespace, entity);
  return signalData.hasValue && signalData.isActive;
}

function entityIsInactiveSignal(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
  SignalData memory signalData = Signal.get(callerNamespace, entity);
  return signalData.hasValue && !signalData.isActive;
}

function clearCoord(address world, VoxelCoord memory coord) returns (bytes32) {
  bytes memory returnData = safeCall(world, abi.encodeWithSignature(CLEAR_COORD_SIG, coord), "clearCoord");
  return abi.decode(returnData, (bytes32));
}

function build(address world, VoxelCoord memory coord, bytes32 entity) returns (bytes32) {
  bytes memory returnData = safeCall(world, abi.encodeWithSignature(BUILD_SIG, entity, coord), "build");
  return abi.decode(returnData, (bytes32));
}

function giftVoxel(address world, bytes16 voxelTypeNamespace, bytes32 voxelTypeId) returns (bytes32) {
  bytes memory returnData = safeCall(
    world,
    abi.encodeWithSignature(GIFT_VOXEL_SIG, voxelTypeNamespace, voxelTypeId),
    "giftVoxel"
  );
  return abi.decode(returnData, (bytes32));
}

function removeAllOwnedVoxels(address world) {
  safeCall(world, abi.encodeWithSignature(RM_ALL_OWNED_VOXELS_SIG), "removeAllVoxels");
}
