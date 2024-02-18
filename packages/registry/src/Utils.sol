// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { ObjectTypeRegistry } from "@tenet-registry/src/codegen/tables/ObjectTypeRegistry.sol";

function getObjectAddress(IStore store, bytes32 objectTypeId) view returns (address) {
  return ObjectTypeRegistry.getContractAddress(store, objectTypeId);
}

function getObjectStackable(IStore store, bytes32 objectTypeId) view returns (uint8) {
  return ObjectTypeRegistry.getStackable(store, objectTypeId);
}

function getEnterWorldSelector(IStore store, bytes32 objectTypeId) view returns (address, bytes4) {
  return (getObjectAddress(store, objectTypeId), ObjectTypeRegistry.getEnterWorldSelector(store, objectTypeId));
}

function getExitWorldSelector(IStore store, bytes32 objectTypeId) view returns (address, bytes4) {
  return (getObjectAddress(store, objectTypeId), ObjectTypeRegistry.getExitWorldSelector(store, objectTypeId));
}

function getEventHandlerSelector(IStore store, bytes32 objectTypeId) view returns (address, bytes4) {
  return (getObjectAddress(store, objectTypeId), ObjectTypeRegistry.getEventHandlerSelector(store, objectTypeId));
}

function getNeighbourEventHandlerSelector(IStore store, bytes32 objectTypeId) view returns (address, bytes4) {
  return (
    getObjectAddress(store, objectTypeId),
    ObjectTypeRegistry.getNeighbourEventHandlerSelector(store, objectTypeId)
  );
}
