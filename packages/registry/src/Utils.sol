// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { REGISTER_BODY_TYPE_SIG, REGISTER_BODY_VARIANT_SIG, REGISTER_CREATION_SIG, GET_VOXELS_IN_CREATION_SIG, CREATION_SPAWNED_SIG, BODY_SPAWNED_SIG, REGISTER_MIND_SIG, REGISTER_MIND_WORLD_SIG } from "@tenet-registry/src/Constants.sol";
import { BodyVariantsRegistryData } from "@tenet-registry/src/codegen/tables/BodyVariantsRegistry.sol";
import { BodyTypeRegistry } from "@tenet-registry/src/codegen/tables/BodyTypeRegistry.sol";
import { VoxelCoord, BaseCreationInWorld, BodyTypeData, BodySelectors, InteractionSelector, Mind } from "@tenet-utils/src/Types.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

function registerBodyVariant(
  address registryAddress,
  bytes32 bodyVariantId,
  BodyVariantsRegistryData memory bodyVariantData
) returns (bytes memory) {
  return
    safeCall(
      registryAddress,
      abi.encodeWithSignature(REGISTER_BODY_VARIANT_SIG, bodyVariantId, bodyVariantData),
      "registerBodyVariant"
    );
}

function registerBodyType(
  address registryAddress,
  string memory name,
  bytes32 bodyTypeId,
  bytes32 baseBodyTypeId,
  bytes32[] memory childBodyTypeIds,
  bytes32[] memory schemaBodyTypeIds,
  bytes32 previewBodyVariantId,
  BodySelectors memory bodySelectors
) returns (bytes memory) {
  return
    safeCall(
      registryAddress,
      abi.encodeWithSignature(
        REGISTER_BODY_TYPE_SIG,
        name,
        bodyTypeId,
        baseBodyTypeId,
        childBodyTypeIds,
        schemaBodyTypeIds,
        previewBodyVariantId,
        bodySelectors
      ),
      "registerBodyType"
    );
}

function bodySelectorsForVoxel(
  bytes4 enterWorldSelector,
  bytes4 exitWorldSelector,
  bytes4 bodyVariantSelector,
  bytes4 activateSelector,
  bytes4 interactionSelector
) pure returns (BodySelectors memory) {
  InteractionSelector[] memory voxelInteractionSelectors = new InteractionSelector[](1);
  voxelInteractionSelectors[0] = InteractionSelector({
    interactionSelector: interactionSelector,
    interactionName: "Default",
    interactionDescription: ""
  });
  return
    BodySelectors({
      enterWorldSelector: enterWorldSelector,
      exitWorldSelector: exitWorldSelector,
      bodyVariantSelector: bodyVariantSelector,
      activateSelector: activateSelector,
      onNewNeighbourSelector: bytes4(0),
      interactionSelectors: voxelInteractionSelectors
    });
}

function getEnterWorldSelector(IStore store, bytes32 bodyTypeId) view returns (bytes4) {
  bytes memory selectors = BodyTypeRegistry.getSelectors(store, bodyTypeId);
  return abi.decode(selectors, (BodySelectors)).enterWorldSelector;
}

function getExitWorldSelector(IStore store, bytes32 bodyTypeId) view returns (bytes4) {
  bytes memory selectors = BodyTypeRegistry.getSelectors(store, bodyTypeId);
  return abi.decode(selectors, (BodySelectors)).exitWorldSelector;
}

function getBodyVariantSelector(IStore store, bytes32 bodyTypeId) view returns (bytes4) {
  bytes memory selectors = BodyTypeRegistry.getSelectors(store, bodyTypeId);
  return abi.decode(selectors, (BodySelectors)).bodyVariantSelector;
}

function getActivateSelector(IStore store, bytes32 bodyTypeId) view returns (bytes4) {
  bytes memory selectors = BodyTypeRegistry.getSelectors(store, bodyTypeId);
  return abi.decode(selectors, (BodySelectors)).activateSelector;
}

function getOnNewNeighbourSelector(IStore store, bytes32 bodyTypeId) view returns (bytes4) {
  bytes memory selectors = BodyTypeRegistry.getSelectors(store, bodyTypeId);
  return abi.decode(selectors, (BodySelectors)).onNewNeighbourSelector;
}

function getInteractionSelectors(IStore store, bytes32 bodyTypeId) view returns (InteractionSelector[] memory) {
  bytes memory selectors = BodyTypeRegistry.getSelectors(store, bodyTypeId);
  return abi.decode(selectors, (BodySelectors)).interactionSelectors;
}

function registerCreation(
  address registryAddress,
  string memory name,
  string memory description,
  BodyTypeData[] memory bodyTypes,
  VoxelCoord[] memory voxelCoords,
  BaseCreationInWorld[] memory baseCreationsInWorld
) returns (bytes32, VoxelCoord memory, BodyTypeData[] memory, VoxelCoord[] memory) {
  bytes memory result = safeCall(
    registryAddress,
    abi.encodeWithSignature(REGISTER_CREATION_SIG, name, description, bodyTypes, voxelCoords, baseCreationsInWorld),
    "registerCreation"
  );
  return abi.decode(result, (bytes32, VoxelCoord, BodyTypeData[], VoxelCoord[]));
}

function getVoxelsInCreation(
  address registryAddress,
  bytes32 creationId
) returns (VoxelCoord[] memory, BodyTypeData[] memory) {
  bytes memory result = safeCall(
    registryAddress,
    abi.encodeWithSignature(GET_VOXELS_IN_CREATION_SIG, creationId),
    "getVoxelsInCreation"
  );
  return abi.decode(result, (VoxelCoord[], BodyTypeData[]));
}

function creationSpawned(address registryAddress, bytes32 creationId) returns (uint256) {
  bytes memory result = safeCall(
    registryAddress,
    abi.encodeWithSignature(CREATION_SPAWNED_SIG, creationId),
    "creationSpawned"
  );
  return abi.decode(result, (uint256));
}

function bodySpawned(address registryAddress, bytes32 bodyTypeId) returns (uint256) {
  bytes memory result = safeCall(registryAddress, abi.encodeWithSignature(BODY_SPAWNED_SIG, bodyTypeId), "bodySpawned");
  return abi.decode(result, (uint256));
}

function registerMindIntoRegistry(
  address registryAddress,
  bytes32 bodyTypeId,
  Mind memory mind
) returns (bytes memory) {
  return safeCall(registryAddress, abi.encodeWithSignature(REGISTER_MIND_SIG, bodyTypeId, mind), "registerMind");
}

function registerMindForWorld(
  address registryAddress,
  bytes32 bodyTypeId,
  address worldAddress,
  Mind memory mind
) returns (bytes memory) {
  return
    safeCall(
      registryAddress,
      abi.encodeWithSignature(REGISTER_MIND_WORLD_SIG, bodyTypeId, worldAddress, mind),
      "registerMindForWorld"
    );
}
