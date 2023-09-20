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

abstract contract CA is System {
  function getRegistryAddress() internal pure virtual returns (address);

  function registerCA() public virtual;

  function emptyVoxelId() internal pure virtual returns (bytes32) {}

  function callVoxelEnterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) internal virtual;

  function callVoxelExitWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) internal virtual;

  function callVoxelRunInteraction(
    bytes4 interactionSelector,
    bytes32 voxelTypeId,
    bytes32 caInteractEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal virtual returns (bytes32[] memory);

  function callGetVoxelVariant(
    bytes32 voxelTypeId,
    bytes32 caEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal virtual returns (bytes32);

  function terrainGen(
    address callerAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes32 entity
  ) internal virtual {
    CAPosition.set(callerAddress, entity, CAPositionData({ x: coord.x, y: coord.y, z: coord.z }));
    bytes32 caEntity = getUniqueEntity();
    CAEntityMapping.set(callerAddress, entity, caEntity);
    CAEntityReverseMapping.set(caEntity, callerAddress, entity);
  }

  function isVoxelTypeAllowed(bytes32 voxelTypeId) public view returns (bool) {
    bytes32[] memory voxelTypeIds = CARegistry.getVoxelTypeIds(IStore(getRegistryAddress()), _world());
    for (uint256 i = 0; i < voxelTypeIds.length; i++) {
      if (voxelTypeIds[i] == voxelTypeId) {
        return true;
      }
    }
    return false;
  }

  function getMindSelector(bytes32 entity) public view virtual returns (bytes4) {
    address callerAddress = _msgSender();
    bytes32 caEntity = entityToCAEntity(callerAddress, entity);
    require(hasKey(CAMindTableId, CAMind.encodeKeyTuple(caEntity)), "Mind does not exist");
    return CAMind.getMindSelector(caEntity);
  }

  function setMindSelector(bytes32 entity, bytes4 mindSelector) public virtual {
    address callerAddress = _msgSender();
    bytes32 caEntity = entityToCAEntity(callerAddress, entity);
    require(hasKey(CAMindTableId, CAMind.encodeKeyTuple(caEntity)), "Mind does not exist");
    CAMind.setMindSelector(caEntity, mindSelector);
  }

  function enterWorld(
    bytes32 voxelTypeId,
    bytes4 mindSelector,
    VoxelCoord memory coord,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public {
    address callerAddress = _msgSender();
    require(isVoxelTypeAllowed(voxelTypeId), "CASystem: This voxel type is not allowed in this CA");

    // Check if we can set the voxel type at this position
    bytes32 existingEntity = getEntityAtCoord(IStore(_world()), callerAddress, coord);
    bytes32 caEntity;
    if (existingEntity != 0) {
      require(
        CAVoxelType.get(callerAddress, existingEntity).voxelTypeId == emptyVoxelId(),
        "EnterWorld: This position is already occupied by another voxel"
      );
      caEntity = entityToCAEntity(callerAddress, entity);
    } else {
      require(!hasKey(CAEntityMappingTableId, CAEntityMapping.encodeKeyTuple(callerAddress, entity)), "Entity exists");
      CAPosition.set(callerAddress, entity, CAPositionData({ x: coord.x, y: coord.y, z: coord.z }));
      caEntity = getUniqueEntity();
      CAEntityMapping.set(callerAddress, entity, caEntity);
      CAEntityReverseMapping.set(caEntity, callerAddress, entity);
    }
    CAMind.set(caEntity, voxelTypeId, mindSelector);

    bytes32[] memory caNeighbourEntityIds = entityArrayToCAEntityArray(callerAddress, neighbourEntityIds);

    callVoxelEnterWorld(voxelTypeId, coord, caEntity);

    bytes32 voxelVariantId = callGetVoxelVariant(
      voxelTypeId,
      caEntity,
      caNeighbourEntityIds,
      childEntityIds,
      parentEntity
    );
    CAVoxelType.set(callerAddress, entity, voxelTypeId, voxelVariantId);
  }

  function exitWorld(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public {
    if (voxelTypeId == emptyVoxelId()) {
      return;
    }

    address callerAddress = _msgSender();
    if (!hasKey(CAPositionTableId, CAPosition.encodeKeyTuple(callerAddress, entity))) {
      terrainGen(callerAddress, voxelTypeId, coord, entity);
    }

    bytes32 caEntity = entityToCAEntity(callerAddress, entity);
    bytes32[] memory caNeighbourEntityIds = entityArrayToCAEntityArray(callerAddress, neighbourEntityIds);

    // set to Air
    bytes32 airVoxelVariantId = callGetVoxelVariant(
      emptyVoxelId(),
      caEntity,
      caNeighbourEntityIds,
      childEntityIds,
      parentEntity
    );
    CAVoxelType.set(callerAddress, entity, emptyVoxelId(), airVoxelVariantId);

    callVoxelExitWorld(voxelTypeId, coord, caEntity);

    CAMind.set(caEntity, voxelTypeId, bytes4(0)); // emoty voxel has no mind
  }

  function moveWorld(
    bytes32 voxelTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bytes32 newEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public {
    address callerAddress = _msgSender();
    require(isVoxelTypeAllowed(voxelTypeId), "CASystem: This voxel type is not allowed in this CA");

    bytes32 oldEntity = getEntityAtCoord(IStore(_world()), callerAddress, oldCoord);
    require(oldEntity != 0, "No entity at old coord");

    // Set to old entity Air
    bytes32 oldCAEntity = entityToCAEntity(callerAddress, oldEntity);
    // TODO: Note these neighbour, child, and parent are NOT for the old coord
    // But for air, we don't need them.
    {
      bytes32 airVoxelVariantId = callGetVoxelVariant(
        emptyVoxelId(),
        bytes32(0),
        new bytes32[](0),
        new bytes32[](0),
        bytes32(0)
      );
      CAVoxelType.set(callerAddress, oldEntity, emptyVoxelId(), airVoxelVariantId);
    }
    // Set new entity to voxel type
    bytes32 existingEntity = getEntityAtCoord(IStore(_world()), callerAddress, newCoord);
    bytes32 newCAEntity;
    if (existingEntity != 0) {
      require(
        CAVoxelType.get(callerAddress, existingEntity).voxelTypeId == emptyVoxelId(),
        "MoveWorld: This position is already occupied by another voxel"
      );
      newCAEntity = entityToCAEntity(callerAddress, newEntity);
    } else {
      require(
        !hasKey(CAEntityMappingTableId, CAEntityMapping.encodeKeyTuple(callerAddress, newEntity)),
        "Entity exists"
      );
      CAPosition.set(callerAddress, newEntity, CAPositionData({ x: newCoord.x, y: newCoord.y, z: newCoord.z }));
      newCAEntity = getUniqueEntity();
      // TODO: should there be a mind for this new entity?
      CAMind.set(newCAEntity, voxelTypeId, bytes4(0));
      // CAEntityMapping.set(callerAddress, newEntity, newCAEntity);
      // CAEntityReverseMapping.set(newCAEntity, callerAddress, newEntity);
    }

    // Update CA entity mapping from old to new
    // Note: This is the main move of the pointer
    CAEntityMapping.set(callerAddress, oldEntity, newCAEntity);
    CAEntityReverseMapping.set(newCAEntity, callerAddress, oldEntity);
    CAEntityMapping.set(callerAddress, newEntity, oldCAEntity);
    CAEntityReverseMapping.set(oldCAEntity, callerAddress, newEntity);

    moveWorldHelper(
      callerAddress,
      oldCAEntity,
      newEntity,
      voxelTypeId,
      neighbourEntityIds,
      childEntityIds,
      parentEntity
    );
  }

  function moveWorldHelper(
    address callerAddress,
    bytes32 oldCAEntity,
    bytes32 newEntity,
    bytes32 voxelTypeId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal {
    bytes32[] memory caNeighbourEntityIds = entityArrayToCAEntityArray(callerAddress, neighbourEntityIds);
    bytes32 voxelVariantId = callGetVoxelVariant(
      voxelTypeId,
      oldCAEntity, // This needs to be the old one, since it's a move
      caNeighbourEntityIds,
      childEntityIds,
      parentEntity
    );
    CAVoxelType.set(callerAddress, newEntity, voxelTypeId, voxelVariantId);
  }

  function runInteraction(
    bytes4 interactionSelector,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32[] memory changedEntities) {
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
    bytes32[] memory changedCAEntities = callVoxelRunInteraction(
      interactionSelector,
      voxelTypeId,
      caInteractEntity,
      caNeighbourEntityIds,
      childEntityIds,
      parentEntity
    );

    // Neighbour Interactions
    for (uint256 i = 0; i < neighbourEntityIds.length; i++) {
      if (neighbourEntityIds[i] != 0) {
        bytes32 neighbourVoxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, neighbourEntityIds[i]);
        if (
          !shouldRunInteractionForNeighbour(
            callerAddress,
            VoxelEntity({
              scale: VoxelTypeRegistry.getScale(IStore(getRegistryAddress()), voxelTypeId),
              entityId: interactEntity
            }),
            VoxelEntity({
              scale: VoxelTypeRegistry.getScale(IStore(getRegistryAddress()), neighbourVoxelTypeId),
              entityId: neighbourEntityIds[i]
            })
          )
        ) {
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
        bytes32[] memory changedCANeighbourEntities = callVoxelRunInteraction(
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
      }
    }

    changedEntities = caEntityArrayToEntityArray(changedCAEntities);
    // Update voxel types after interaction
    updateVoxelTypes(callerAddress, changedEntities);

    return changedEntities;
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

  function activateVoxel(bytes32 entity) public returns (string memory) {
    address callerAddress = _msgSender();
    bytes32 voxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, entity);
    bytes4 voxelActivateSelector = getActivateSelector(IStore(getRegistryAddress()), voxelTypeId);
    bytes32 caEntity = entityToCAEntity(callerAddress, entity);
    bytes memory returnData = safeCall(
      _world(),
      abi.encodeWithSelector(voxelActivateSelector, caEntity),
      "voxel activate"
    );
    return abi.decode(returnData, (string));
  }
}
