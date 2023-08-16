// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { BodyTypeRegistry } from "@tenet-registry/src/codegen/tables/BodyTypeRegistry.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { CAPosition, CAPositionData, CAPositionTableId } from "@tenet-base-ca/src/codegen/tables/CAPosition.sol";
import { CAMind, CAMindTableId } from "@tenet-base-ca/src/codegen/tables/CAMind.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { CAEntityReverseMapping } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { CABodyType, CABodyTypeTableId } from "@tenet-base-ca/src/codegen/tables/CABodyType.sol";
import { VoxelCoord, InteractionSelector } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, entityArrayToCAEntityArray, entityToCAEntity, caEntityArrayToEntityArray } from "@tenet-base-ca/src/Utils.sol";
import { getNeighbourEntitiesFromCaller, getChildEntitiesFromCaller, getParentEntityFromCaller } from "@tenet-base-ca/src/CallUtils.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { getEnterWorldSelector, getExitWorldSelector, getBodyVariantSelector, getActivateSelector, getInteractionSelectors, getOnNewNeighbourSelector } from "@tenet-registry/src/Utils.sol";

abstract contract CAHelper is System {
  function getRegistryAddress() internal pure virtual returns (address);

  function bodyEnterWorld(bytes32 bodyTypeId, VoxelCoord memory coord, bytes32 caEntity) public virtual {
    bytes32 baseBodyTypeId = BodyTypeRegistry.getBaseBodyTypeId(IStore(getRegistryAddress()), bodyTypeId);
    if (baseBodyTypeId != bodyTypeId) {
      bodyEnterWorld(baseBodyTypeId, coord, caEntity); // recursive, so we get the entire stack of russian dolls
    }
    bytes4 bodyEnterWorldSelector = getEnterWorldSelector(IStore(getRegistryAddress()), bodyTypeId);
    safeCall(_world(), abi.encodeWithSelector(bodyEnterWorldSelector, coord, caEntity), "body enter world");
  }

  function getBodyVariant(
    bytes32 bodyTypeId,
    bytes32 caEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public virtual returns (bytes32) {
    bytes4 bodyVariantSelector = getBodyVariantSelector(IStore(getRegistryAddress()), bodyTypeId);
    bytes memory returnData = safeStaticCall(
      _world(),
      abi.encodeWithSelector(bodyVariantSelector, caEntity, caNeighbourEntityIds, childEntityIds, parentEntity),
      "voxel variant selector"
    );
    return abi.decode(returnData, (bytes32));
  }

  function bodyExitWorld(bytes32 bodyTypeId, VoxelCoord memory coord, bytes32 caEntity) public virtual {
    bytes4 bodyExitWorldSelector = getExitWorldSelector(IStore(getRegistryAddress()), bodyTypeId);
    safeCall(_world(), abi.encodeWithSelector(bodyExitWorldSelector, coord, caEntity), "body exit world");

    bytes32 baseBodyTypeId = BodyTypeRegistry.getBaseBodyTypeId(IStore(getRegistryAddress()), bodyTypeId);
    if (baseBodyTypeId != bodyTypeId) {
      bodyExitWorld(baseBodyTypeId, coord, caEntity); // recursive, so we get the entire stack of russian dolls
    }
  }

  function bodyRunInteraction(
    bytes4 interactionSelector,
    bytes32 bodyTypeId,
    bytes32 caInteractEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public virtual returns (bytes32[] memory) {
    bytes32[] memory changedCAEntities = new bytes32[](caNeighbourEntityIds.length + 1);

    bytes32 baseBodyTypeId = BodyTypeRegistry.getBaseBodyTypeId(IStore(getRegistryAddress()), bodyTypeId);
    if (baseBodyTypeId != bodyTypeId) {
      bytes32[] memory insideChangedCAEntityIds = bodyRunInteraction(
        bytes4(0),
        baseBodyTypeId,
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
    // Call mind to figure out whch body interaction to run
    require(hasKey(CAMindTableId, CAMind.encodeKeyTuple(caInteractEntity)), "Mind does not exist");
    bytes4 mindSelector = CAMind.getMindSelector(caInteractEntity);

    InteractionSelector[] memory interactionSelectors = getInteractionSelectors(
      IStore(getRegistryAddress()),
      bodyTypeId
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
            bodyTypeId,
            caInteractEntity,
            caNeighbourEntityIds,
            childEntityIds,
            parentEntity
          ),
          "run mind"
        );
        useinteractionSelector = abi.decode(mindReturnData, (bytes4));
        if (useinteractionSelector == bytes4(0)) {
          // The mind has chosen to not run a body interaction
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
      "body interaction selector"
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
