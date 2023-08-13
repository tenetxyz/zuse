// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { CAPosition, CAPositionData, CAPositionTableId } from "@tenet-base-ca/src/codegen/tables/CAPosition.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { CAEntityReverseMapping } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { CAVoxelType, CAVoxelTypeTableId } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, entityArrayToCAEntityArray, entityToCAEntity, caEntityArrayToEntityArray } from "@tenet-base-ca/src/Utils.sol";
import { getNeighbourEntitiesFromCaller, getChildEntitiesFromCaller, getParentEntityFromCaller } from "@tenet-base-ca/src/CallUtils.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";

abstract contract CA is System {
  function getRegistryAddress() internal pure virtual returns (address);

  function registerCA() public virtual;

  function emptyVoxelId() internal pure virtual returns (bytes32) {}

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

  function voxelEnterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) internal {
    bytes32 baseVoxelTypeId = VoxelTypeRegistry.getBaseVoxelTypeId(IStore(getRegistryAddress()), voxelTypeId);
    if (baseVoxelTypeId != voxelTypeId) {
      voxelEnterWorld(baseVoxelTypeId, coord, caEntity); // recursive, so we get the entire stack of russian dolls
    }
    bytes4 voxelEnterWorldSelector = VoxelTypeRegistry.getEnterWorldSelector(IStore(getRegistryAddress()), voxelTypeId);
    safeCall(_world(), abi.encodeWithSelector(voxelEnterWorldSelector, coord, caEntity), "voxel enter world");
  }

  function enterWorld(
    bytes32 voxelTypeId,
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
    if (existingEntity != 0) {
      require(
        CAVoxelType.get(callerAddress, existingEntity).voxelTypeId == emptyVoxelId(),
        "This position is already occupied by another voxel"
      );
    } else {
      CAPosition.set(callerAddress, entity, CAPositionData({ x: coord.x, y: coord.y, z: coord.z }));
    }

    bytes32 caEntity;
    if (!hasKey(CAEntityMappingTableId, CAEntityMapping.encodeKeyTuple(callerAddress, entity))) {
      caEntity = getUniqueEntity();
      CAEntityMapping.set(callerAddress, entity, caEntity);
      CAEntityReverseMapping.set(caEntity, callerAddress, entity);
    } else {
      caEntity = entityToCAEntity(callerAddress, entity);
    }

    bytes32[] memory caNeighbourEntityIds = entityArrayToCAEntityArray(callerAddress, neighbourEntityIds);

    voxelEnterWorld(voxelTypeId, coord, caEntity);

    bytes32 voxelVariantId = getVoxelVariant(voxelTypeId, caEntity, caNeighbourEntityIds, childEntityIds, parentEntity);
    CAVoxelType.set(callerAddress, entity, voxelTypeId, voxelVariantId);
  }

  function getVoxelVariant(
    bytes32 voxelTypeId,
    bytes32 caEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32) {
    bytes4 voxelVariantSelector = VoxelTypeRegistry.getVoxelVariantSelector(IStore(getRegistryAddress()), voxelTypeId);
    bytes memory returnData = safeStaticCall(
      _world(),
      abi.encodeWithSelector(voxelVariantSelector, caEntity, caNeighbourEntityIds, childEntityIds, parentEntity),
      "voxel variant selector"
    );
    return abi.decode(returnData, (bytes32));
  }

  function voxelExitWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) internal {
    bytes4 voxelExitWorldSelector = VoxelTypeRegistry.getExitWorldSelector(IStore(getRegistryAddress()), voxelTypeId);
    safeCall(_world(), abi.encodeWithSelector(voxelExitWorldSelector, coord, caEntity), "voxel exit world");

    bytes32 baseVoxelTypeId = VoxelTypeRegistry.getBaseVoxelTypeId(IStore(getRegistryAddress()), voxelTypeId);
    if (baseVoxelTypeId != voxelTypeId) {
      voxelExitWorld(baseVoxelTypeId, coord, caEntity); // recursive, so we get the entire stack of russian dolls
    }
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
    bytes32 airVoxelVariantId = getVoxelVariant(
      emptyVoxelId(),
      caEntity,
      caNeighbourEntityIds,
      childEntityIds,
      parentEntity
    );
    CAVoxelType.set(callerAddress, entity, emptyVoxelId(), airVoxelVariantId);

    voxelExitWorld(voxelTypeId, coord, caEntity);
  }

  function voxelRunInteraction(
    bytes32 voxelTypeId,
    bytes32 caInteractEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal returns (bytes32[] memory) {
    bytes32[] memory changedCAEntities = new bytes32[](caNeighbourEntityIds.length + 1);

    bytes32 baseVoxelTypeId = VoxelTypeRegistry.getBaseVoxelTypeId(IStore(getRegistryAddress()), voxelTypeId);
    if (baseVoxelTypeId != voxelTypeId) {
      bytes32[] memory insideChangedCAEntityIds = voxelRunInteraction(
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
    bytes4 interactionSelector = VoxelTypeRegistry.getInteractionSelector(IStore(getRegistryAddress()), voxelTypeId);
    bytes memory returnData = safeCall(
      _world(),
      abi.encodeWithSelector(interactionSelector, caInteractEntity, caNeighbourEntityIds, childEntityIds, parentEntity),
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

  function runInteraction(
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

    // TODO: Call update function before calling mind

    // TODO: Call mind to figure out whch voxel interaction to run

    // Note: Center and Neighbour could just be different interfaces, but then the user would have to
    // define two, so instead we just call one interface and pass in the entity ids

    // Center Interaction
    bytes32[] memory changedCAEntities = voxelRunInteraction(
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
        // Call voxel interaction
        bytes32[] memory changedCANeighbourEntities = voxelRunInteraction(
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
      bytes32 changedEntity = changedEntities[i];
      if (changedEntity != 0) {
        bytes32 changedVoxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, changedEntity);
        uint32 scale = VoxelTypeRegistry.getScale(IStore(getRegistryAddress()), changedVoxelTypeId);
        bytes32 voxelVariantId = getVoxelVariant(
          changedVoxelTypeId,
          entityToCAEntity(callerAddress, changedEntity),
          entityArrayToCAEntityArray(
            callerAddress,
            getNeighbourEntitiesFromCaller(callerAddress, scale, changedEntity)
          ),
          getChildEntitiesFromCaller(callerAddress, scale, changedEntity),
          getParentEntityFromCaller(callerAddress, scale, changedEntity)
        );
        CAVoxelType.set(callerAddress, changedEntity, changedVoxelTypeId, voxelVariantId);
      }
    }
  }

  function activateVoxel(bytes32 entity) public returns (string memory) {
    address callerAddress = _msgSender();
    bytes32 voxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, entity);
    bytes4 voxelActivateSelector = VoxelTypeRegistry.getActivateSelector(IStore(getRegistryAddress()), voxelTypeId);
    bytes32 caEntity = entityToCAEntity(callerAddress, entity);
    bytes memory returnData = safeCall(
      _world(),
      abi.encodeWithSelector(voxelActivateSelector, caEntity),
      "voxel activate"
    );
    return abi.decode(returnData, (string));
  }
}
