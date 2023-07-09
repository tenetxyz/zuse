// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { VoxelCoord } from "@tenet-contracts/src/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Signal, SignalData, SignalSource, Powered, InvertedSignal } from "@tenet-extension-contracts/src/codegen/Tables.sol";
import { CLEAR_COORD_SIG, BUILD_SIG, GIFT_VOXEL_SIG } from "@tenet-contracts/src/constants.sol";
import { Signal, SignalSource, Powered, InvertedSignal, Temperature } from "./codegen/Tables.sol";
import { Signal, SignalSource, Powered, InvertedSignal, Temperature, Generator } from "./codegen/Tables.sol";
import { BlockDirection } from "./codegen/Types.sol";
import { CLEAR_COORD_SIG, BUILD_SIG } from "@tenetxyz/contracts/src/constants.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { REGISTER_EXTENSION_SIG, REGISTER_VOXEL_TYPE_SIG, REGISTER_VOXEL_VARIANT_SIG, RM_ALL_OWNED_VOXELS_SIG } from "@tenet-contracts/src/constants.sol";
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

function entityIsActiveSignal(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
  SignalData memory signalData = Signal.get(callerNamespace, entity);
  return signalData.hasValue && signalData.isActive;
}

function entityIsInactiveSignal(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
  SignalData memory signalData = Signal.get(callerNamespace, entity);
  return signalData.hasValue && !signalData.isActive;
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

function entityHasTemperature(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
  return Temperature.get(callerNamespace, entity).hasValue;
}

function entityIsGenerator(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
  return Generator.get(callerNamespace, entity).hasValue;
}

function calculateBlockDirection(
  PositionData memory centerCoord,
  PositionData memory neighborCoord
) pure returns (BlockDirection) {
  if (neighborCoord.x == centerCoord.x && neighborCoord.y == centerCoord.y && neighborCoord.z == centerCoord.z) {
    return BlockDirection.None;
  } else if (neighborCoord.y > centerCoord.y) {
    return BlockDirection.Up;
  } else if (neighborCoord.y < centerCoord.y) {
    return BlockDirection.Down;
  } else if (neighborCoord.z > centerCoord.z) {
    return BlockDirection.North;
  } else if (neighborCoord.z < centerCoord.z) {
    return BlockDirection.South;
  } else if (neighborCoord.x > centerCoord.x) {
    return BlockDirection.East;
  } else if (neighborCoord.x < centerCoord.x) {
    return BlockDirection.West;
  } else {
    return BlockDirection.None;
  }
}

function removeAllOwnedVoxels(address world) {
  safeCall(world, abi.encodeWithSignature(RM_ALL_OWNED_VOXELS_SIG), "removeAllVoxels");
}
