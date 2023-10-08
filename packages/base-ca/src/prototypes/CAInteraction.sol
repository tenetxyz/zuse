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
import { VoxelCoord, InteractionSelector, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, entityArrayToCAEntityArray, entityToCAEntity, caEntityArrayToEntityArray } from "@tenet-base-ca/src/Utils.sol";
import { getNeighbourEntitiesFromCaller, getChildEntitiesFromCaller, getParentEntityFromCaller, shouldRunInteractionForNeighbour } from "@tenet-base-ca/src/CallUtils.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";
import { getEnterWorldSelector, getExitWorldSelector, getVoxelVariantSelector, getActivateSelector, getInteractionSelectors, getOnNewNeighbourSelector } from "@tenet-registry/src/Utils.sol";

abstract contract CAInteraction is System {
  function getRegistryAddress() internal pure virtual returns (address);

  function callGetVoxelVariant(
    bytes32 voxelTypeId,
    bytes32 caEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal virtual returns (bytes32);

  function voxelRunInteraction(
    bytes4 interactionSelector,
    bytes32 voxelTypeId,
    bytes32 caInteractEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal virtual returns (bytes32, bytes memory) {
    bytes32 changedCenterEntityId;
    bytes memory centerEntityEventData;

    {
      // handle base voxel types
      bytes32 baseVoxelTypeId = VoxelTypeRegistry.getBaseVoxelTypeId(IStore(getRegistryAddress()), voxelTypeId);
      if (baseVoxelTypeId != voxelTypeId) {
        (bytes32 insideChangedCenterEntityId, bytes memory insideCenterEntityEventData) = voxelRunInteraction(
          bytes4(0),
          baseVoxelTypeId,
          caInteractEntity,
          caNeighbourEntityIds,
          childEntityIds,
          parentEntity
        ); // recursive, so we get the entire stack of russian dolls

        if (changedCenterEntityId == 0 && insideChangedCenterEntityId != 0) {
          changedCenterEntityId = insideChangedCenterEntityId;
        }

        if (centerEntityEventData.length == 0 && insideCenterEntityEventData.length != 0) {
          centerEntityEventData = insideCenterEntityEventData;
        }
      }
    }
    bytes4 useinteractionSelector = 0;
    {
      // Call mind to figure out whch voxel interaction to run
      require(hasKey(CAMindTableId, CAMind.encodeKeyTuple(caInteractEntity)), "Mind does not exist");
      bytes4 mindSelector = CAMind.getMindSelector(caInteractEntity);

      InteractionSelector[] memory interactionSelectors = getInteractionSelectors(
        IStore(getRegistryAddress()),
        voxelTypeId
      );
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
            if (interactionSelectors.length > 0) {
              // Note: we could return and not run any if the mind doesn't pick an interaction
              // however, we run the first one instead for voxel types to ensure specific behaviour always runs
              useinteractionSelector = interactionSelectors[0].interactionSelector;
            } else {
              // This voxel has no interaction selectors, so we don't run any interaction
              return (changedCenterEntityId, centerEntityEventData);
            }
          }
        } else {
          if (interactionSelectors.length == 1) {
            // use the first one, if there's only one
            useinteractionSelector = interactionSelectors[0].interactionSelector;
          } else {
            // This voxel has no mind and no interaction selector, so we don't run any interaction
            return (changedCenterEntityId, centerEntityEventData);
          }
        }
      }
    }
    require(useinteractionSelector != 0, "Interaction selector not found");

    {
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

      (bool changedCACenterEntityId, bytes memory entityEventData) = abi.decode(returnData, (bool, bytes));

      if (changedCenterEntityId == 0 && changedCACenterEntityId) {
        changedCenterEntityId = caInteractEntity;
      }

      if (centerEntityEventData.length == 0 && entityEventData.length != 0) {
        centerEntityEventData = entityEventData;
      }
    }

    return (changedCenterEntityId, centerEntityEventData);
  }

  function runNeighbourInteractionsHelper(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId
  ) internal view returns (bool) {
    bytes32 voxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, interactEntity);
    bytes32 neighbourVoxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, neighbourEntityId);
    return
      shouldRunInteractionForNeighbour(
        callerAddress,
        VoxelEntity({
          scale: VoxelTypeRegistry.getScale(IStore(getRegistryAddress()), voxelTypeId),
          entityId: interactEntity
        }),
        VoxelEntity({
          scale: VoxelTypeRegistry.getScale(IStore(getRegistryAddress()), neighbourVoxelTypeId),
          entityId: neighbourEntityId
        })
      );
  }

  function runNeighbourInteractions(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32 caInteractEntity,
    bytes32[] memory caNeighbourEntityIds
  ) internal returns (bytes32[] memory, bytes[] memory) {
    bytes32[] memory changedNeighbourEntities = new bytes32[](neighbourEntityIds.length);
    bytes[] memory neighbourEntitiesEventData = new bytes[](neighbourEntityIds.length);
    for (uint256 i = 0; i < neighbourEntityIds.length; i++) {
      if (neighbourEntityIds[i] != 0) {
        bytes32 neighbourVoxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, neighbourEntityIds[i]);
        if (!runNeighbourInteractionsHelper(callerAddress, interactEntity, neighbourEntityIds[i])) {
          continue;
        }

        bytes4 onNewNeighbourSelector = getOnNewNeighbourSelector(IStore(getRegistryAddress()), neighbourVoxelTypeId);
        if (onNewNeighbourSelector != bytes4(0)) {
          bytes memory returnData = safeCall(
            _world(),
            abi.encodeWithSelector(onNewNeighbourSelector, caNeighbourEntityIds[i], caInteractEntity),
            "onNewNeighbourSelector"
          );
          (bool changedNeighbour, bytes memory entityEventData) = abi.decode(returnData, (bool, bytes));
          if (changedNeighbour) {
            changedNeighbourEntities[i] = caNeighbourEntityIds[i];
          }
          if (entityEventData.length != 0) {
            neighbourEntitiesEventData[i] = entityEventData;
          }
        }
      }
    }

    return (changedNeighbourEntities, neighbourEntitiesEventData);
  }

  function runInteraction(
    bytes4 interactionSelector,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public virtual returns (bytes32[] memory, bytes[] memory) {
    address callerAddress = _msgSender();
    require(
      hasKey(CAVoxelTypeTableId, CAVoxelType.encodeKeyTuple(callerAddress, interactEntity)),
      "Entity does not exist for runInteraction"
    );
    bytes32 voxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, interactEntity);

    bytes32 caInteractEntity = entityToCAEntity(callerAddress, interactEntity);
    bytes32[] memory caNeighbourEntityIds = entityArrayToCAEntityArray(callerAddress, neighbourEntityIds);

    // Center Interaction
    (bytes32 changedCenterEntityId, bytes memory centerEntityEventData) = voxelRunInteraction(
      interactionSelector,
      voxelTypeId,
      caInteractEntity,
      caNeighbourEntityIds,
      childEntityIds,
      parentEntity
    );

    // Neighbour Interactions
    (bytes32[] memory changedNeighbourEntities, bytes[] memory neighbourEntitiesEventData) = runNeighbourInteractions(
      callerAddress,
      interactEntity,
      neighbourEntityIds,
      caInteractEntity,
      caNeighbourEntityIds
    );

    bytes32[] memory changedCAEntities = new bytes32[](changedNeighbourEntities.length + 1);
    bytes[] memory caEntitiesEventData = new bytes[](neighbourEntitiesEventData.length + 1);
    // Note: If the center changes, there will be another event for it again before the neighbours
    // You could move this to be after the neighbour events
    changedCAEntities[0] = changedCenterEntityId;
    for (uint i = 0; i < changedNeighbourEntities.length; i++) {
      changedCAEntities[i + 1] = changedNeighbourEntities[i];
    }
    caEntitiesEventData[0] = centerEntityEventData;
    for (uint i = 0; i < neighbourEntitiesEventData.length; i++) {
      caEntitiesEventData[i + 1] = neighbourEntitiesEventData[i];
    }

    bytes32[] memory changedEntities = caEntityArrayToEntityArray(changedCAEntities);
    // Update voxel types after interaction
    updateVoxelTypes(callerAddress, changedEntities);

    return (changedEntities, caEntitiesEventData);
  }

  function updateVoxelTypes(address callerAddress, bytes32[] memory changedEntities) internal {
    for (uint256 i = 0; i < changedEntities.length; i++) {
      bytes32 changedEntityId = changedEntities[i];
      if (changedEntityId != 0) {
        bytes32 changedVoxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, changedEntityId);
        uint32 scale = VoxelTypeRegistry.getScale(IStore(getRegistryAddress()), changedVoxelTypeId);
        VoxelEntity memory changedEntity = VoxelEntity({ scale: scale, entityId: changedEntityId });
        bytes32 voxelVariantId = callGetVoxelVariant(
          changedVoxelTypeId,
          entityToCAEntity(callerAddress, changedEntityId),
          entityArrayToCAEntityArray(callerAddress, getNeighbourEntitiesFromCaller(callerAddress, changedEntity)),
          getChildEntitiesFromCaller(callerAddress, changedEntity),
          getParentEntityFromCaller(callerAddress, changedEntity)
        );
        CAVoxelType.set(callerAddress, changedEntityId, changedVoxelTypeId, voxelVariantId);
      }
    }
  }
}
