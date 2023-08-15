// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { CAPosition, CAPositionData, CAPositionTableId } from "@tenet-base-ca/src/codegen/tables/CAPosition.sol";
import { CAMind, CAMindTableId } from "@tenet-base-ca/src/codegen/tables/CAMind.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { CAEntityReverseMapping } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { CAVoxelType, CAVoxelTypeTableId } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { VoxelCoord, InteractionSelector } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, entityArrayToCAEntityArray, entityToCAEntity, caEntityArrayToEntityArray } from "@tenet-base-ca/src/Utils.sol";
import { getNeighbourEntitiesFromCaller, getChildEntitiesFromCaller, getParentEntityFromCaller } from "@tenet-base-ca/src/CallUtils.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { getEnterWorldSelector, getExitWorldSelector, getVoxelVariantSelector, getActivateSelector, getInteractionSelectors, getOnNewNeighbourSelector } from "@tenet-registry/src/Utils.sol";

abstract contract CAHelper is System {
  function getRegistryAddress() internal pure virtual returns (address);

  function voxelEnterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) public virtual {
    bytes32 baseVoxelTypeId = VoxelTypeRegistry.getBaseVoxelTypeId(IStore(getRegistryAddress()), voxelTypeId);
    if (baseVoxelTypeId != voxelTypeId) {
      voxelEnterWorld(baseVoxelTypeId, coord, caEntity); // recursive, so we get the entire stack of russian dolls
    }
    bytes4 voxelEnterWorldSelector = getEnterWorldSelector(IStore(getRegistryAddress()), voxelTypeId);
    safeCall(_world(), abi.encodeWithSelector(voxelEnterWorldSelector, coord, caEntity), "voxel enter world");
  }

  function getVoxelVariant(
    bytes32 voxelTypeId,
    bytes32 caEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public virtual returns (bytes32) {
    bytes4 voxelVariantSelector = getVoxelVariantSelector(IStore(getRegistryAddress()), voxelTypeId);
    bytes memory returnData = safeStaticCall(
      _world(),
      abi.encodeWithSelector(voxelVariantSelector, caEntity, caNeighbourEntityIds, childEntityIds, parentEntity),
      "voxel variant selector"
    );
    return abi.decode(returnData, (bytes32));
  }

  function voxelExitWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) public virtual {
    bytes4 voxelExitWorldSelector = getExitWorldSelector(IStore(getRegistryAddress()), voxelTypeId);
    safeCall(_world(), abi.encodeWithSelector(voxelExitWorldSelector, coord, caEntity), "voxel exit world");

    bytes32 baseVoxelTypeId = VoxelTypeRegistry.getBaseVoxelTypeId(IStore(getRegistryAddress()), voxelTypeId);
    if (baseVoxelTypeId != voxelTypeId) {
      voxelExitWorld(baseVoxelTypeId, coord, caEntity); // recursive, so we get the entire stack of russian dolls
    }
  }

  function voxelRunInteraction(
    bytes4 interactionSelector,
    bytes32 voxelTypeId,
    bytes32 caInteractEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public virtual returns (bytes32[] memory) {
    bytes32[] memory changedCAEntities = new bytes32[](caNeighbourEntityIds.length + 1);

    bytes32 baseVoxelTypeId = VoxelTypeRegistry.getBaseVoxelTypeId(IStore(getRegistryAddress()), voxelTypeId);
    if (baseVoxelTypeId != voxelTypeId) {
      bytes32[] memory insideChangedCAEntityIds = voxelRunInteraction(
        bytes4(0),
        baseVoxelTypeId,
        caInteractEntity,
        caNeighbourEntityIds,
        childEntityIds,
        parentEntity
      ); // recursive, so we get the entire stack of russian dolls

      for (uint256 i = 0; i < insideChangedCAEntityIds.length; i++) {
        if (changedCAEntities[i] == 0 && insideChangedCAEntityIds[i] != 0) {
          changedCAEntities[i] = insideChangedCAEntityIds[i];
        }
      }
    }
    // Call mind to figure out whch voxel interaction to run
    require(hasKey(CAMindTableId, CAMind.encodeKeyTuple(caInteractEntity)), "Mind does not exist");
    bytes4 mindSelector = CAMind.getMindSelector(caInteractEntity);

    InteractionSelector[] memory interactionSelectors = getInteractionSelectors(
      IStore(getRegistryAddress()),
      voxelTypeId
    );
    bytes4 useinteractionSelector = 0;
    if (interactionSelector != bytes4(0)) {
      for (uint256 i = 0; i < interactionSelectors.length; i++) {
        if (interactionSelectors[i].interactionSelector == interactionSelector) {
          useinteractionSelector = interactionSelector;
          break;
        }
      }
    } else {
      if (mindSelector != bytes4(0)) {
        // call mind to figure out which interaction selector to use
        bytes memory mindReturnData = safeCall(
          _world(),
          abi.encodeWithSelector(
            mindSelector,
            voxelTypeId,
            caInteractEntity,
            caNeighbourEntityIds,
            childEntityIds,
            parentEntity
          ),
          "voxel activate"
        );
        useinteractionSelector = abi.decode(mindReturnData, (bytes4));
        if (useinteractionSelector == bytes4(0)) {
          // The mind has chosen to not run a voxel interaction
          return changedCAEntities;
        }
      } else {
        useinteractionSelector = interactionSelectors[0].interactionSelector; // use the first one
      }
    }
    require(useinteractionSelector != 0, "Interaction selector not found");

    bytes memory returnData = safeCall(
      _world(),
      abi.encodeWithSelector(
        useinteractionSelector,
        caInteractEntity,
        caNeighbourEntityIds,
        childEntityIds,
        parentEntity
      ),
      "voxel interaction selector"
    );

    (bytes32 changedCACenterEntityId, bytes32[] memory changedCANeighbourEntityIds) = abi.decode(
      returnData,
      (bytes32, bytes32[])
    );

    if (changedCAEntities[0] == 0 && changedCACenterEntityId != 0) {
      changedCAEntities[0] = changedCACenterEntityId;
    }

    for (uint256 i = 0; i < changedCANeighbourEntityIds.length; i++) {
      if (changedCAEntities[i + 1] == 0 && changedCANeighbourEntityIds[i] != 0) {
        changedCAEntities[i + 1] = changedCANeighbourEntityIds[i];
      }
    }

    return changedCAEntities;
  }
}
