// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { ObjectProperties } from "@tenet-utils/src/Types.sol";

interface IInventorySystem {
  function addObjectToInventory(
    bytes32 objectEntityId,
    bytes32 objectTypeId,
    uint8 numObjectsToAdd,
    ObjectProperties memory objectProperties
  ) external;

  function removeObjectFromInventory(bytes32 inventoryId, uint8 numObjectsToRemove) external;
}
