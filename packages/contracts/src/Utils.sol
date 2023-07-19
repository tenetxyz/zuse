// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { CHUNK } from "@tenet-contracts/src/Constants.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Coord, VoxelCoord } from "@tenet-contracts/src/Types.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { Position, PositionData, PositionTableId, VoxelType, VoxelTypeRegistry, VoxelTypeRegistryData, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { VoxelVariantsKey, BlockDirection } from "@tenet-contracts/src/Types.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

function getCallerNamespace(address caller) view returns (bytes16) {
  require(uint256(SystemRegistry.get(caller)) != 0, "Caller is not a system"); // cannot be called by an EOA
  bytes32 resourceSelector = SystemRegistry.get(caller);
  bytes16 callerNamespace = ResourceSelector.getNamespace(resourceSelector);
  return callerNamespace;
}

function getEntityPositionStrict(bytes32 entity) view returns (PositionData memory) {
  bytes32[] memory positionKeyTuple = new bytes32[](1);
  positionKeyTuple[0] = bytes32((entity));
  require(hasKey(PositionTableId, positionKeyTuple), "Entity must have a position"); // even if its air, it must have a position
  return Position.get(entity);
}

function calculateBlockDirection(
  VoxelCoord memory centerCoord,
  VoxelCoord memory neighborCoord
) pure returns (BlockDirection) {
  return
    calculateBlockDirection(
      PositionData(centerCoord.x, centerCoord.y, centerCoord.z),
      PositionData(neighborCoord.x, neighborCoord.y, neighborCoord.z)
    );
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

function getPositionAtDirection(
  VoxelCoord memory centerCoord,
  BlockDirection direction
) pure returns (VoxelCoord memory) {
  int32 newX = centerCoord.x;
  int32 newY = centerCoord.y;
  int32 newZ = centerCoord.z;
  if (direction == BlockDirection.None) {
    return centerCoord;
  } else if (direction == BlockDirection.Up) {
    newY += 1;
  } else if (direction == BlockDirection.Down) {
    newY -= 1;
  } else if (direction == BlockDirection.North) {
    newZ += 1;
  } else if (direction == BlockDirection.South) {
    newZ -= 1;
  } else if (direction == BlockDirection.East) {
    newX += 1;
  } else if (direction == BlockDirection.West) {
    newX -= 1;
  } else {
    return centerCoord;
  }
  return VoxelCoord(newX, newY, newZ);
}

function getVoxelVariant(
  address world,
  bytes16 voxelTypeNamespace,
  bytes32 voxelTypeId,
  bytes32 entity
) returns (VoxelVariantsKey memory) {
  bytes4 voxelVariantSelector = VoxelTypeRegistry.get(voxelTypeNamespace, voxelTypeId).voxelVariantSelector;
  bytes memory voxelVariantSelected = safeStaticCall(
    world,
    abi.encodeWithSelector(voxelVariantSelector, entity),
    "get voxel variant"
  );
  return abi.decode(voxelVariantSelected, (VoxelVariantsKey));
}

function enterVoxelIntoWorld(address world, bytes32 entity) {
  VoxelTypeData memory entityVoxelType = VoxelType.get(entity);
  bytes4 enterWorldSelector = VoxelTypeRegistry
    .get(entityVoxelType.voxelTypeNamespace, entityVoxelType.voxelTypeId)
    .enterWorldSelector;
  safeCall(world, abi.encodeWithSelector(enterWorldSelector, entity), "voxel enter world");
}

function exitVoxelFromWorld(address world, bytes32 entity) {
  VoxelTypeData memory entityVoxelType = VoxelType.get(entity);
  bytes4 exitWorldSelector = VoxelTypeRegistry
    .get(entityVoxelType.voxelTypeNamespace, entityVoxelType.voxelTypeId)
    .exitWorldSelector;
  safeCall(world, abi.encodeWithSelector(exitWorldSelector, entity), "voxel exit world");
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

function safeStaticCallFunctionSelector(
  address world,
  bytes4 functionPointer,
  bytes memory args
) returns (bytes memory) {
  return safeStaticCall(world, bytes.concat(functionPointer, args), "staticcall function selector");
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

function sub(VoxelCoord memory a, VoxelCoord memory b) pure returns (VoxelCoord memory) {
  return VoxelCoord(a.x - b.x, a.y - b.y, a.z - b.z);
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

function removeEntityFromArray(bytes32[] memory entities, bytes32 entity) pure returns (bytes32[] memory) {
  bytes32[] memory updatedArray = new bytes32[](entities.length - 1);
  uint index = 0;

  // Copy elements from the original array to the updated array, excluding the entity
  for (uint i = 0; i < entities.length; i++) {
    if (entities[i] != entity) {
      updatedArray[index] = entities[i];
      index++;
    }
  }

  return updatedArray;
}

function hasEntity(bytes32[] memory entities) pure returns (bool) {
  for (uint256 i; i < entities.length; i++) {
    if (uint256(entities[i]) != 0) {
      return true;
    }
  }
  return false;
}

enum CallType {
  Call,
  StaticCall,
  DelegateCall
}

// bubbles up a revert reason string if the call fails
function safeGenericCall(
  CallType callType,
  address target,
  bytes memory callData,
  string memory functionName
) returns (bytes memory) {
  bool success;
  bytes memory returnData;

  if (callType == CallType.Call) {
    (success, returnData) = target.call(callData);
  } else if (callType == CallType.StaticCall) {
    (success, returnData) = target.staticcall(callData);
  } else if (callType == CallType.DelegateCall) {
    (success, returnData) = target.delegatecall(callData);
  }

  if (!success) {
    // if there is a return reason string
    if (returnData.length > 0) {
      // bubble up any reason for revert
      assembly {
        let returnDataSize := mload(returnData)
        revert(add(32, returnData), returnDataSize)
      }
    } else {
      string memory revertMsg = string(
        abi.encodePacked(functionName, " call reverted. Maybe the params aren't right?")
      );
      revert(revertMsg);
    }
  }

  return returnData;
}

function safeCall(address target, bytes memory callData, string memory functionName) returns (bytes memory) {
  return safeGenericCall(CallType.Call, target, callData, functionName);
}

function safeStaticCall(address target, bytes memory callData, string memory functionName) returns (bytes memory) {
  return safeGenericCall(CallType.StaticCall, target, callData, functionName);
}

function safeDelegateCall(address target, bytes memory callData, string memory functionName) returns (bytes memory) {
  return safeGenericCall(CallType.DelegateCall, target, callData, functionName);
}

function getVoxelCoordStrict(bytes32 entity) view returns (VoxelCoord memory) {
  PositionData memory position = getEntityPositionStrict(entity);
  return VoxelCoord(position.x, position.y, position.z);
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

function voxelCoordsAreEqual(VoxelCoord memory c1, VoxelCoord memory c2) pure returns (bool) {
  return c1.x == c2.x && c1.y == c2.y && c1.z == c2.z;
}
