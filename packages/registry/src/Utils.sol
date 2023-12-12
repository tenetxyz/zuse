// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";

import { ObjectTypeRegistry } from "@tenet-registry/src/codegen/tables/ObjectTypeRegistry.sol";

import { REGISTER_OBJECT_TYPE_SIG, REGISTER_DECISION_RULE_SIG, REGISTER_MIND_SIG } from "@tenet-registry/src/Constants.sol";

import { VoxelCoord, Mind } from "@tenet-utils/src/Types.sol";
import { callOrRevert } from "@tenet-utils/src/CallUtils.sol";

function registerObjectType(
  address registryAddress,
  bytes32 objectTypeId,
  address contractAddress,
  bytes4 enterWorldSelector,
  bytes4 exitWorldSelector,
  bytes4 eventHandlerSelector,
  bytes4 neighbourEventHandlerSelector,
  string memory name,
  string memory description
) returns (bytes memory) {
  return
    callOrRevert(
      registryAddress,
      abi.encodeWithSignature(
        REGISTER_OBJECT_TYPE_SIG,
        objectTypeId,
        contractAddress,
        enterWorldSelector,
        exitWorldSelector,
        eventHandlerSelector,
        neighbourEventHandlerSelector,
        name,
        description
      ),
      "registerObjectType"
    );
}

function registerDecisionRule(
  address registryAddress,
  bytes32 srcObjectTypeId,
  bytes32 targetObjectTypeId,
  address decisionRuleAddress,
  bytes4 decisionRuleSelector,
  string memory name,
  string memory description
) returns (bytes memory) {
  return
    callOrRevert(
      registryAddress,
      abi.encodeWithSignature(
        REGISTER_DECISION_RULE_SIG,
        srcObjectTypeId,
        targetObjectTypeId,
        decisionRuleAddress,
        decisionRuleSelector,
        name,
        description
      ),
      "registerDecisionRule"
    );
}

function registerMind(
  address registryAddress,
  bytes32 objectTypeId,
  address mindAddress,
  bytes4 mindSelector,
  string memory name,
  string memory description
) returns (bytes memory) {
  return
    callOrRevert(
      registryAddress,
      abi.encodeWithSignature(REGISTER_MIND_SIG, objectTypeId, mindAddress, mindSelector, name, description),
      "registerMind"
    );
}

function getObjectAddress(IStore store, bytes32 objectTypeId) view returns (address) {
  return ObjectTypeRegistry.getContractAddress(store, objectTypeId);
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
