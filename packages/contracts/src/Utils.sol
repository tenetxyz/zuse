// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { CHUNK } from "./constants.sol";
import { Coord, VoxelCoord } from "./types.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { Position, PositionTableId } from "./codegen/Tables.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

function staticcallFunctionSelector(address world, bytes4 functionPointer, bytes memory args) view returns (bool, bytes memory){
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

function int32ToString(int32 num) pure returns (string memory){
    return Strings.toString(uint256(uint32(num)));
}

function add(VoxelCoord memory a, VoxelCoord memory b) pure returns (VoxelCoord memory) {
    return VoxelCoord(a.x + b.x, a.y + b.y, a.z + b.z);
}
function voxelCoordToString(VoxelCoord memory coord) pure returns (string memory) {
    return string(abi.encodePacked("(", int32ToString(coord.x), ", ", int32ToString(coord.y), ", ", int32ToString(coord.z), ")"));
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

// Thus function gets around solidity's horrible lack of dynamic arrays, sets, and data structure support
// Note: this is O(n^2) and will be slow for large arrays
function removeDuplicates(bytes32[] memory arr) pure returns (bytes32[] memory) {
    bytes32[] memory uniqueArray = new bytes32[](arr.length);
    uint uniqueCount = 0;

    for (uint i = 0; i < arr.length; i++) {
        bool isDuplicate = false;
        for (uint j = 0; j < uniqueCount; j++) {
            if (arr[i] == uniqueArray[j]) {
                isDuplicate = true;
                break;
            }
        }
        if (!isDuplicate) {
            uniqueArray[uniqueCount] = arr[i];
            uniqueCount++;
        }
    }

    bytes32[] memory result = new bytes32[](uniqueCount);
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