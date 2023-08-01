// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";

function getCallerNamespace(address caller) view returns (bytes16) {
  require(uint256(SystemRegistry.get(caller)) != 0, "Caller is not a system"); // cannot be called by an EOA
  bytes32 resourceSelector = SystemRegistry.get(caller);
  bytes16 callerNamespace = ResourceSelector.getNamespace(resourceSelector);
  return callerNamespace;
}

function addressToEntityKey(address addr) pure returns (bytes32) {
  return bytes32(uint256(uint160(addr)));
}

function hasEntity(bytes32[] memory entities) pure returns (bool) {
  for (uint256 i; i < entities.length; i++) {
    if (uint256(entities[i]) != 0) {
      return true;
    }
  }
  return false;
}

function initializeArray(uint256 x, uint256 y) pure returns (uint256[][] memory) {
  uint256[][] memory arr = new uint256[][](x);
  for (uint256 i; i < x; i++) {
    arr[i] = new uint256[](y);
  }
  return arr;
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

function entityArraysAreEqual(bytes32[] memory arr1, bytes32[] memory arr2) pure returns (bool) {
  if (arr1.length != arr2.length) {
    return false;
  }

  for (uint i = 0; i < arr1.length; i++) {
    if (arr1[i] != arr2[i]) {
      return false;
    }
  }

  return true;
}