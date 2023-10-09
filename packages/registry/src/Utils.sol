// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { REGISTER_VOXEL_TYPE_SIG, REGISTER_VOXEL_VARIANT_SIG, REGISTER_CREATION_SIG, GET_VOXELS_IN_CREATION_SIG, CREATION_SPAWNED_SIG, VOXEL_SPAWNED_SIG, REGISTER_DECISION_RULE_SIG, REGISTER_MIND_SIG, REGISTER_MIND_WORLD_SIG } from "@tenet-registry/src/Constants.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { VoxelCoord, BaseCreationInWorld, VoxelTypeData, VoxelSelectors, InteractionSelector, Mind } from "@tenet-utils/src/Types.sol";
import { isStringEqual } from "@tenet-utils/src/StringUtils.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

function registerVoxelVariant(
  address registryAddress,
  bytes32 voxelVariantId,
  VoxelVariantsRegistryData memory voxelVariantData
) returns (bytes memory) {
  return
    safeCall(
      registryAddress,
      abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, voxelVariantId, voxelVariantData),
      "registerVoxelVariant"
    );
}

function registerVoxelType(
  address registryAddress,
  string memory name,
  bytes32 voxelTypeId,
  bytes32 baseVoxelTypeId,
  bytes32[] memory childVoxelTypeIds,
  bytes32[] memory schemaVoxelTypeIds,
  bytes32 previewVoxelVariantId,
  VoxelSelectors memory voxelSelectors,
  bytes memory componentDefs
) returns (bytes memory) {
  return
    safeCall(
      registryAddress,
      abi.encodeWithSignature(
        REGISTER_VOXEL_TYPE_SIG,
        name,
        voxelTypeId,
        baseVoxelTypeId,
        childVoxelTypeIds,
        schemaVoxelTypeIds,
        previewVoxelVariantId,
        voxelSelectors,
        componentDefs
      ),
      "registerVoxelType"
    );
}

function voxelSelectorsForVoxel(
  bytes4 enterWorldSelector,
  bytes4 exitWorldSelector,
  bytes4 voxelVariantSelector,
  bytes4 activateSelector,
  bytes4 interactionSelector,
  bytes4 onNewNeighbourSelector
) pure returns (VoxelSelectors memory) {
  InteractionSelector[] memory voxelInteractionSelectors = new InteractionSelector[](1);
  voxelInteractionSelectors[0] = InteractionSelector({
    interactionSelector: interactionSelector,
    interactionName: "Default",
    interactionDescription: ""
  });
  return
    VoxelSelectors({
      enterWorldSelector: enterWorldSelector,
      exitWorldSelector: exitWorldSelector,
      voxelVariantSelector: voxelVariantSelector,
      activateSelector: activateSelector,
      onNewNeighbourSelector: onNewNeighbourSelector,
      interactionSelectors: voxelInteractionSelectors
    });
}

function getEnterWorldSelector(IStore store, bytes32 voxelTypeId) view returns (bytes4) {
  bytes memory selectors = VoxelTypeRegistry.getSelectors(store, voxelTypeId);
  return abi.decode(selectors, (VoxelSelectors)).enterWorldSelector;
}

function getExitWorldSelector(IStore store, bytes32 voxelTypeId) view returns (bytes4) {
  bytes memory selectors = VoxelTypeRegistry.getSelectors(store, voxelTypeId);
  return abi.decode(selectors, (VoxelSelectors)).exitWorldSelector;
}

function getVoxelVariantSelector(IStore store, bytes32 voxelTypeId) view returns (bytes4) {
  bytes memory selectors = VoxelTypeRegistry.getSelectors(store, voxelTypeId);
  return abi.decode(selectors, (VoxelSelectors)).voxelVariantSelector;
}

function getActivateSelector(IStore store, bytes32 voxelTypeId) view returns (bytes4) {
  bytes memory selectors = VoxelTypeRegistry.getSelectors(store, voxelTypeId);
  return abi.decode(selectors, (VoxelSelectors)).activateSelector;
}

function getOnNewNeighbourSelector(IStore store, bytes32 voxelTypeId) view returns (bytes4) {
  bytes memory selectors = VoxelTypeRegistry.getSelectors(store, voxelTypeId);
  return abi.decode(selectors, (VoxelSelectors)).onNewNeighbourSelector;
}

function getInteractionSelectors(IStore store, bytes32 voxelTypeId) view returns (InteractionSelector[] memory) {
  bytes memory selectors = VoxelTypeRegistry.getSelectors(store, voxelTypeId);
  return abi.decode(selectors, (VoxelSelectors)).interactionSelectors;
}

function getSelector(
  InteractionSelector[] memory interactionSelectors,
  string memory selectorName
) pure returns (bytes4) {
  for (uint i = 0; i < interactionSelectors.length; i++) {
    if (isStringEqual(interactionSelectors[i].interactionName, selectorName)) {
      return interactionSelectors[i].interactionSelector;
    }
  }
  revert("Selector not found");
}

function registerCreation(
  address registryAddress,
  string memory name,
  string memory description,
  VoxelTypeData[] memory voxelTypes,
  VoxelCoord[] memory voxelCoords,
  BaseCreationInWorld[] memory baseCreationsInWorld
) returns (bytes32, VoxelCoord memory, VoxelTypeData[] memory, VoxelCoord[] memory) {
  bytes memory result = safeCall(
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
  bytes memory result = safeCall(
    registryAddress,
    abi.encodeWithSignature(GET_VOXELS_IN_CREATION_SIG, creationId),
    "getVoxelsInCreation"
  );
  return abi.decode(result, (VoxelCoord[], VoxelTypeData[]));
}

function creationSpawned(address registryAddress, bytes32 creationId) returns (uint256) {
  bytes memory result = safeCall(
    registryAddress,
    abi.encodeWithSignature(CREATION_SPAWNED_SIG, creationId),
    "creationSpawned"
  );
  return abi.decode(result, (uint256));
}

function voxelSpawned(address registryAddress, bytes32 voxelTypeId) returns (uint256) {
  bytes memory result = safeCall(
    registryAddress,
    abi.encodeWithSignature(VOXEL_SPAWNED_SIG, voxelTypeId),
    "voxelSpawned"
  );
  return abi.decode(result, (uint256));
}

function registerDecisionRule(
  address registryAddress,
  string memory name,
  string memory description,
  bytes32 srcVoxelTypeId,
  bytes32 targetVoxelTypeId,
  bytes4 decisionRuleSelector
) returns (bytes memory) {
  return
    safeCall(
      registryAddress,
      abi.encodeWithSignature(
        REGISTER_DECISION_RULE_SIG,
        name,
        description,
        srcVoxelTypeId,
        targetVoxelTypeId,
        decisionRuleSelector
      ),
      "registerDecisionRule"
    );
}

function registerMindIntoRegistry(
  address registryAddress,
  bytes32 voxelTypeId,
  string memory name,
  string memory description,
  bytes4 mindSelector
) returns (bytes memory) {
  return
    safeCall(
      registryAddress,
      abi.encodeWithSignature(REGISTER_MIND_SIG, voxelTypeId, name, description, mindSelector),
      "registerMind"
    );
}

function registerMindForWorld(
  address registryAddress,
  bytes32 voxelTypeId,
  address worldAddress,
  string memory name,
  string memory description,
  bytes4 mindSelector
) returns (bytes memory) {
  return
    safeCall(
      registryAddress,
      abi.encodeWithSignature(REGISTER_MIND_WORLD_SIG, voxelTypeId, worldAddress, name, description, mindSelector),
      "registerMindForWorld"
    );
}
