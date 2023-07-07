// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { CHUNK } from "./Constants.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Coord, VoxelCoord } from "./Types.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { Position, PositionData, PositionTableId, VoxelType, VoxelTypeRegistry, VoxelTypeRegistryData, VoxelTypeData } from "./codegen/Tables.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { VoxelVariantsKey, BlockDirection } from "./Types.sol";

function getEntityPositionStrict(bytes32 entity) view returns (PositionData memory) {
  bytes32[] memory positionKeyTuple = new bytes32[](1);
  positionKeyTuple[0] = bytes32((entity));
  require(hasKey(PositionTableId, positionKeyTuple), "Entity must have a position"); // even if its air, it must have a position
  return Position.get(entity);
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

function getVoxelVariant(
  address world,
  bytes16 voxelTypeNamespace,
  bytes32 voxelTypeId,
  bytes32 entity
) returns (VoxelVariantsKey memory) {
  bytes4 voxelVariantSelector = VoxelTypeRegistry.get(voxelTypeNamespace, voxelTypeId).voxelVariantSelector;
  (bool variantSelectorSuccess, bytes memory voxelVariantSelected) = world.call(
    abi.encodeWithSelector(voxelVariantSelector, entity)
  );
  require(variantSelectorSuccess, "failed to get voxel variant");
  return abi.decode(voxelVariantSelected, (VoxelVariantsKey));
}

function updateVoxelVariant(address world, bytes32 entity) {
  VoxelTypeData memory entityVoxelType = VoxelType.get(entity);
  VoxelVariantsKey memory voxelVariantData = getVoxelVariant(
    world,
    entityVoxelType.voxelTypeNamespace,
    entityVoxelType.voxelTypeId,
    entity
  );
  if (
    voxelVariantData.voxelVariantNamespace != entityVoxelType.voxelVariantNamespace ||
    voxelVariantData.voxelVariantId != entityVoxelType.voxelVariantId
  ) {
    VoxelType.set(
      entity,
      entityVoxelType.voxelTypeNamespace,
      entityVoxelType.voxelTypeId,
      voxelVariantData.voxelVariantNamespace,
      voxelVariantData.voxelVariantId
    );
  }
}

function staticcallFunctionSelector(
  address world,
  bytes4 functionPointer,
  bytes memory args
) view returns (bool, bytes memory) {
  return world.staticcall(bytes.concat(functionPointer, args));
}

function addressToEntityKey(address addr) pure returns (bytes32) {
  return bytes32(uint256(uint160(addr)));
}

// Divide with rounding down like Math.floor(a/b), not rounding towards zero
function div(int32 a, int32 b) pure returns (int32) {
  int32 result = a / b;
  int32 floor = (a < 0 || b < 0) && !(a < 0 && b < 0) && (a % b != 0) ? int32(1) : int32(0);
  return result - floor;
}

function getChunkCoord(VoxelCoord memory coord) pure returns (Coord memory) {
  return Coord(div(coord.x, CHUNK), div(coord.z, CHUNK));
}

function int32ToString(int32 num) pure returns (string memory) {
  return Strings.toString(int256(num));
}

function bytes4ToString(bytes4 num) pure returns (string memory) {
  return Strings.toString(uint256(uint32(num)));
}

function add(VoxelCoord memory a, VoxelCoord memory b) pure returns (VoxelCoord memory) {
  return VoxelCoord(a.x + b.x, a.y + b.y, a.z + b.z);
}

function voxelCoordToString(VoxelCoord memory coord) pure returns (string memory) {
  return
    string(
      abi.encodePacked("(", int32ToString(coord.x), ", ", int32ToString(coord.y), ", ", int32ToString(coord.z), ")")
    );
}

function initializeArray(uint256 x, uint256 y) pure returns (uint256[][] memory) {
  uint256[][] memory arr = new uint256[][](x);
  for (uint256 i; i < x; i++) {
    arr[i] = new uint256[](y);
  }
  return arr;
}

function getEntitiesAtCoord(VoxelCoord memory coord) view returns (bytes32[] memory) {
  return getKeysWithValue(PositionTableId, Position.encode(coord.x, coord.y, coord.z));
}

function increaseVoxelTypeSpawnCount(bytes16 voxelTypeNamespace, bytes32 voxelTypeId) {
  VoxelTypeRegistryData memory voxelTypeRegistryData = VoxelTypeRegistry.get(voxelTypeNamespace, voxelTypeId);
  voxelTypeRegistryData.numSpawns += 1;
  VoxelTypeRegistry.set(voxelTypeNamespace, voxelTypeId, voxelTypeRegistryData);
}

// Thus function gets around solidity's horrible lack of dynamic arrays, sets, and data structure support
// Note: this is O(n^2) and will be slow for large arrays
function removeDuplicates(bytes[] memory arr) pure returns (bytes[] memory) {
  bytes[] memory uniqueArray = new bytes[](arr.length);
  uint uniqueCount = 0;

  for (uint i = 0; i < arr.length; i++) {
    bool isDuplicate = false;
    for (uint j = 0; j < uniqueCount; j++) {
      if (keccak256(arr[i]) == keccak256(uniqueArray[j])) {
        isDuplicate = true;
        break;
      }
    }
    if (!isDuplicate) {
      uniqueArray[uniqueCount] = arr[i];
      uniqueCount++;
    }
  }

  bytes[] memory result = new bytes[](uniqueCount);
  for (uint i = 0; i < uniqueCount; i++) {
    result[i] = uniqueArray[i];
  }
  return result;
}

function hasEntity(bytes32[] memory entities) pure returns (bool) {
  for (uint256 i; i < entities.length; i++) {
    if (uint256(entities[i]) != 0) {
      return true;
    }
  }
  return false;
}
