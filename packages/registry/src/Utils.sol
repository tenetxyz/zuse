// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { REGISTER_OBJECT_TYPE_SIG, REGISTER_CREATION_SIG, GET_VOXELS_IN_CREATION_SIG, CREATION_SPAWNED_SIG, VOXEL_SPAWNED_SIG, REGISTER_DECISION_RULE_SIG, REGISTER_MIND_SIG, REGISTER_MIND_WORLD_SIG } from "@tenet-registry/src/Constants.sol";
import { ObjectTypeRegistry } from "@tenet-registry/src/codegen/tables/ObjectTypeRegistry.sol";
import { VoxelCoord, BaseCreationInWorld, VoxelTypeData, VoxelSelectors, InteractionSelector, Mind } from "@tenet-utils/src/Types.sol";
import { isStringEqual } from "@tenet-utils/src/StringUtils.sol";
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

function registerCreation(
  address registryAddress,
  string memory name,
  string memory description,
  VoxelTypeData[] memory voxelTypes,
  VoxelCoord[] memory voxelCoords,
  BaseCreationInWorld[] memory baseCreationsInWorld
) returns (bytes32, VoxelCoord memory, VoxelTypeData[] memory, VoxelCoord[] memory) {
  bytes memory result = callOrRevert(
    registryAddress,
    abi.encodeWithSignature(REGISTER_CREATION_SIG, name, description, voxelTypes, voxelCoords, baseCreationsInWorld),
    "registerCreation"
  );
  return abi.decode(result, (bytes32, VoxelCoord, VoxelTypeData[], VoxelCoord[]));
}

function getVoxelsInCreation(
  address registryAddress,
  bytes32 creationId
) returns (VoxelCoord[] memory, VoxelTypeData[] memory) {
  bytes memory result = callOrRevert(
    registryAddress,
    abi.encodeWithSignature(GET_VOXELS_IN_CREATION_SIG, creationId),
    "getVoxelsInCreation"
  );
  return abi.decode(result, (VoxelCoord[], VoxelTypeData[]));
}

function creationSpawned(address registryAddress, bytes32 creationId) returns (uint256) {
  bytes memory result = callOrRevert(
    registryAddress,
    abi.encodeWithSignature(CREATION_SPAWNED_SIG, creationId),
    "creationSpawned"
  );
  return abi.decode(result, (uint256));
}

function voxelSpawned(address registryAddress, bytes32 objectTypeId) returns (uint256) {
  bytes memory result = callOrRevert(
    registryAddress,
    abi.encodeWithSignature(VOXEL_SPAWNED_SIG, objectTypeId),
    "voxelSpawned"
  );
  return abi.decode(result, (uint256));
}

function registerDecisionRule(
  address registryAddress,
  string memory name,
  string memory description,
  bytes32 srcobjectTypeId,
  bytes32 targetobjectTypeId,
  bytes4 decisionRuleSelector
) returns (bytes memory) {
  return
    callOrRevert(
      registryAddress,
      abi.encodeWithSignature(
        REGISTER_DECISION_RULE_SIG,
        name,
        description,
        srcobjectTypeId,
        targetobjectTypeId,
        decisionRuleSelector
      ),
      "registerDecisionRule"
    );
}

function registerMindIntoRegistry(
  address registryAddress,
  bytes32 objectTypeId,
  string memory name,
  string memory description,
  bytes4 mindSelector
) returns (bytes memory) {
  return
    callOrRevert(
      registryAddress,
      abi.encodeWithSignature(REGISTER_MIND_SIG, objectTypeId, name, description, mindSelector),
      "registerMind"
    );
}

function registerMindForWorld(
  address registryAddress,
  bytes32 objectTypeId,
  address worldAddress,
  string memory name,
  string memory description,
  bytes4 mindSelector
) returns (bytes memory) {
  return
    callOrRevert(
      registryAddress,
      abi.encodeWithSignature(REGISTER_MIND_WORLD_SIG, objectTypeId, worldAddress, name, description, mindSelector),
      "registerMindForWorld"
    );
}
