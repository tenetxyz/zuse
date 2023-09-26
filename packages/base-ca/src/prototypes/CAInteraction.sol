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
  ) internal virtual returns (bytes32[] memory, bytes[] memory) {
    bytes32[] memory changedCAEntities = new bytes32[](caNeighbourEntityIds.length + 1);
    bytes[] memory caEntitiesEventData = new bytes[](caNeighbourEntityIds.length + 1);

    {
      // handle base voxel types
      bytes32 baseVoxelTypeId = VoxelTypeRegistry.getBaseVoxelTypeId(IStore(getRegistryAddress()), voxelTypeId);
      if (baseVoxelTypeId != voxelTypeId) {
        (bytes32[] memory insideChangedCAEntityIds, bytes[] memory insideCAEntitiesEventData) = voxelRunInteraction(
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

        for (uint256 i = 0; i < insideCAEntitiesEventData.length; i++) {
          if (caEntitiesEventData[i].length == 0 && insideCAEntitiesEventData[i].length != 0) {
            caEntitiesEventData[i] = insideCAEntitiesEventData[i];
          }
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
            // The mind has chosen to not run a voxel interaction
            return (changedCAEntities, caEntitiesEventData);
          }
        } else {
          useinteractionSelector = interactionSelectors[0].interactionSelector; // use the first one
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

      (
        bytes32 changedCACenterEntityId,
        bytes32[] memory changedCANeighbourEntityIds,
        bytes[] memory entityEventData
      ) = abi.decode(returnData, (bytes32, bytes32[], bytes[]));

      if (changedCAEntities[0] == 0 && changedCACenterEntityId != 0) {
        changedCAEntities[0] = changedCACenterEntityId;
      }

      for (uint256 i = 0; i < changedCANeighbourEntityIds.length; i++) {
        if (changedCAEntities[i + 1] == 0 && changedCANeighbourEntityIds[i] != 0) {
          changedCAEntities[i + 1] = changedCANeighbourEntityIds[i];
        }
      }

      for (uint256 i = 0; i < entityEventData.length; i++) {
        if (caEntitiesEventData[i].length == 0 && entityEventData[i].length != 0) {
          caEntitiesEventData[i] = entityEventData[i];
        }
      }
    }

    return (changedCAEntities, caEntitiesEventData);
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
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32 caInteractEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity,
    bytes32[] memory changedCAEntities,
    bytes[] memory caEntitiesEventData
  ) internal returns (bytes32[] memory, bytes[] memory) {
    address callerAddress = _msgSender();
    for (uint256 i = 0; i < neighbourEntityIds.length; i++) {
      if (neighbourEntityIds[i] != 0) {
        bytes32 neighbourVoxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, neighbourEntityIds[i]);
        if (!runNeighbourInteractionsHelper(callerAddress, interactEntity, neighbourEntityIds[i])) {
          continue;
        }

        {
          bytes4 onNewNeighbourSelector = getOnNewNeighbourSelector(IStore(getRegistryAddress()), neighbourVoxelTypeId);
          if (onNewNeighbourSelector != bytes4(0)) {
            safeCall(
              _world(),
              abi.encodeWithSelector(onNewNeighbourSelector, caNeighbourEntityIds[i], caInteractEntity),
              "onNewNeighbourSelector"
            );
          }
        }

        // Call voxel interaction
        {
          (
            bytes32[] memory changedCANeighbourEntities,
            bytes[] memory caNeighbourEntitiesEventsData
          ) = voxelRunInteraction(
              bytes4(0),
              neighbourVoxelTypeId,
              caInteractEntity,
              caNeighbourEntityIds,
              childEntityIds,
              parentEntity
            );

          for (uint256 j = 0; j < changedCANeighbourEntities.length; j++) {
            if (changedCAEntities[j] == 0 && changedCANeighbourEntities[j] != 0) {
              changedCAEntities[j] = changedCANeighbourEntities[j];
            }
          }

          for (uint256 j = 0; j < caNeighbourEntitiesEventsData.length; j++) {
            if (caEntitiesEventData[j].length == 0 && caNeighbourEntitiesEventsData[j].length != 0) {
              caEntitiesEventData[j] = caNeighbourEntitiesEventsData[j];
            }
          }
        }
      }
    }

    return (changedCAEntities, caEntitiesEventData);
  }

  function runInteraction(
    bytes4 interactionSelector,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public virtual returns (bytes32[] memory changedEntities, bytes[] memory) {
    address callerAddress = _msgSender();
    require(
      hasKey(CAVoxelTypeTableId, CAVoxelType.encodeKeyTuple(callerAddress, interactEntity)),
      "Entity does not exist"
    );
    bytes32 voxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, interactEntity);

    bytes32 caInteractEntity = entityToCAEntity(callerAddress, interactEntity);
    bytes32[] memory caNeighbourEntityIds = entityArrayToCAEntityArray(callerAddress, neighbourEntityIds);

    // Note: Center and Neighbour could just be different interfaces, but then the user would have to
    // define two, so instead we just call one interface and pass in the entity ids

    // Center Interaction
    (bytes32[] memory changedCAEntities, bytes[] memory caEntitiesEventData) = voxelRunInteraction(
      interactionSelector,
      voxelTypeId,
      caInteractEntity,
      caNeighbourEntityIds,
      childEntityIds,
      parentEntity
    );

    // Neighbour Interactions
    (changedCAEntities, caEntitiesEventData) = runNeighbourInteractions(
      interactEntity,
      neighbourEntityIds,
      caInteractEntity,
      caNeighbourEntityIds,
      childEntityIds,
      parentEntity,
      changedCAEntities,
      caEntitiesEventData
    );

    changedEntities = caEntityArrayToEntityArray(changedCAEntities);
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