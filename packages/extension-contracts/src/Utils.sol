// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { Position, PositionData, PositionTableId } from "@tenetxyz/contracts/src/codegen/tables/Position.sol";
import { VoxelCoord } from "@tenetxyz/contracts/src/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Signal, SignalSource, Powered, InvertedSignal } from "./codegen/Tables.sol";
import { BlockDirection } from "./codegen/Types.sol";
import { CLEAR_COORD_SIG, BUILD_SIG } from "@tenetxyz/contracts/src/constants.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { REGISTER_EXTENSION_SIG, REGISTER_VOXEL_TYPE_SIG, REGISTER_VOXEL_VARIANT_SIG } from "@tenetxyz/contracts/src/constants.sol";
import { VoxelVariantsData } from "./Types.sol";

function registerExtension(address world, string memory extensionName, bytes4 eventHandlerSelector) {
  (bool success, bytes memory result) = world.call(
    abi.encodeWithSignature(REGISTER_EXTENSION_SIG, eventHandlerSelector, extensionName)
  );
  require(success, string(abi.encodePacked("Failed to register extension: ", extensionName)));
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
  (bool success, bytes memory result) = world.call(
    abi.encodeWithSignature(
      REGISTER_VOXEL_TYPE_SIG,
      voxelTypeName,
      voxelTypeId,
      previewVoxelVariantNamespace,
      previewVoxelVariantId,
      variantSelector,
      enterWorldSelector,
      exitWorldSelector
    )
  );
  require(success, string(abi.encodePacked("Failed to register voxelType: ", voxelTypeName)));
}

function registerVoxelVariant(address world, bytes32 voxelVariantId, VoxelVariantsData memory voxelVariantData) {
  (bool success, bytes memory result) = world.call(
    abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, voxelVariantId, voxelVariantData)
  );
  require(success, "Failed to register voxel variant");
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

function getEntityPositionStrict(bytes32 entity) view returns (PositionData memory) {
  bytes32[] memory positionKeyTuple = new bytes32[](1);
  positionKeyTuple[0] = bytes32((entity));
  require(hasKey(PositionTableId, positionKeyTuple), "Entity must have a position"); // even if its air, it must have a position
  return Position.get(entity);
}

function getVoxelCoordStrict(bytes32 entity) view returns (VoxelCoord memory) {
  PositionData memory position = getEntityPositionStrict(entity);
  return VoxelCoord(position.x, position.y, position.z);
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

function getOppositeDirection(BlockDirection direction) pure returns (BlockDirection) {
  if (direction == BlockDirection.None) {
    return BlockDirection.None;
  } else if (direction == BlockDirection.Up) {
    return BlockDirection.Down;
  } else if (direction == BlockDirection.Down) {
    return BlockDirection.Up;
  } else if (direction == BlockDirection.North) {
    return BlockDirection.South;
  } else if (direction == BlockDirection.South) {
    return BlockDirection.North;
  } else if (direction == BlockDirection.East) {
    return BlockDirection.West;
  } else if (direction == BlockDirection.West) {
    return BlockDirection.East;
  } else {
    return BlockDirection.None;
  }
}

function clearCoord(address worldAddress, VoxelCoord memory coord) {
  (bool success, ) = worldAddress.call(abi.encodeWithSignature(CLEAR_COORD_SIG, coord));
  require(success, "Failed to clear voxel");
}

function build(address worldAddress, VoxelCoord memory coord, bytes32 entity) {
  (bool success, ) = worldAddress.call(abi.encodeWithSignature(BUILD_SIG, entity, coord));
  require(success, "Failed to build voxel");
}

function entitiesToVoxelCoords(bytes32[] memory entities) returns (VoxelCoord[] memory) {
  VoxelCoord[] memory coords = new VoxelCoord[](entities.length);
  for (uint256 i; i < entities.length; i++) {
    PositionData memory position = Position.get(entities[i]);
    coords[i] = VoxelCoord(position.x, position.y, position.z);
  }
  return coords;
}

function entitiesToRelativeVoxelCoords(
  bytes32[] memory entities,
  VoxelCoord memory lowerSouthWestCorner
) returns (VoxelCoord[] memory) {
  VoxelCoord[] memory coords = entitiesToVoxelCoords(entities);
  VoxelCoord[] memory relativeCoords = new VoxelCoord[](coords.length);
  for (uint256 i; i < coords.length; i++) {
    relativeCoords[i] = VoxelCoord(
      coords[i].x - lowerSouthWestCorner.x,
      coords[i].y - lowerSouthWestCorner.y,
      coords[i].z - lowerSouthWestCorner.z
    );
  }
  return relativeCoords;
}
