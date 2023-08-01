// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { CAPosition, CAPositionData, CAPositionTableId } from "@tenet-base-ca/src/codegen/tables/CAPosition.sol";
import { CAVoxelConfig, CAVoxelConfigTableId } from "@tenet-base-ca/src/codegen/tables/CAVoxelConfig.sol";
import { CAVoxelType, CAVoxelTypeTableId } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord } from "@tenet-base-ca/src/Utils.sol";
import { REGISTRY_ADDRESS } from "@tenet-base-ca/src/Constants.sol";
import { getNeighbourEntitiesFromCaller, getChildEntitiesFromCaller, getParentEntityFromCaller } from "@tenet-base-ca/src/CallUtils.sol";
import { safeCall, safeStaticCall } from "@tenet-utils/src/CallUtils.sol";

abstract contract CA is System {
  function emptyVoxelId() internal pure virtual returns (bytes32) {}

  function terrainGen(
    address callerAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes32 entity
  ) public virtual;

  function isVoxelTypeAllowed(bytes32 voxelTypeId) public view returns (bool) {
    return hasKey(CAVoxelConfigTableId, CAVoxelConfig.encodeKeyTuple(voxelTypeId));
  }

  function voxelEnterWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) internal {
    bytes32 baseVoxelTypeId = VoxelTypeRegistry.getBaseVoxelTypeId(IStore(REGISTRY_ADDRESS), voxelTypeId);
    while(baseVoxelTypeId != voxelTypeId){
      voxelEnterWorld(callerAddress, baseVoxelTypeId, coord, entity); // recursive, so we get the entire stack of russian dolls
    }
    bytes4 voxelEnterWorldSelector = CAVoxelConfig.getEnterWorldSelector(baseVoxelTypeId);
    safeCall(
      _world(),
      abi.encodeWithSelector(voxelEnterWorldSelector, callerAddress, coord, entity),
      "voxel enter world"
    );
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
    require(isVoxelTypeAllowed(voxelTypeId), "This voxel type is not allowed in this CA");

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

    voxelEnterWorld(callerAddress, voxelTypeId, coord, entity);

    bytes32 voxelVariantId = getVoxelVariant(voxelTypeId, entity, neighbourEntityIds, childEntityIds, parentEntity);
    CAVoxelType.set(callerAddress, entity, voxelTypeId, voxelVariantId);
  }

  function getVoxelVariant(
    bytes32 voxelTypeId,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32) {
    address callerAddress = _msgSender();
    bytes4 voxelVariantSelector = CAVoxelConfig.getVoxelVariantSelector(voxelTypeId);
    bytes memory returnData = safeStaticCall(
      _world(),
      abi.encodeWithSelector(
        voxelVariantSelector,
        callerAddress,
        entity,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      ),
      "voxel variant selector"
    );
    return abi.decode(returnData, (bytes32));
  }

  function voxelExitWorld(address callerAddress, bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) internal {
    bytes4 voxelExitWorldSelector = CAVoxelConfig.getExitWorldSelector(voxelTypeId);
    safeCall(
      _world(),
      abi.encodeWithSelector(voxelExitWorldSelector, callerAddress, coord, entity),
      "voxel exit world"
    );

    bytes32 baseVoxelTypeId = VoxelTypeRegistry.getBaseVoxelTypeId(IStore(REGISTRY_ADDRESS), voxelTypeId);
    if(baseVoxelTypeId != voxelTypeId){
      voxelExitWorld(callerAddress, baseVoxelTypeId, coord, entity); // recursive, so we get the entire stack of russian dolls
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
    // set to Air
    bytes32 airVoxelVariantId = getVoxelVariant(
      emptyVoxelId(),
      entity,
      neighbourEntityIds,
      childEntityIds,
      parentEntity
    );
    CAVoxelType.set(callerAddress, entity, emptyVoxelId(), airVoxelVariantId);

    voxelExitWorld(callerAddress, voxelTypeId, coord, entity);
  }

  function voxelRunInteraction(
    address callerAddress,
    bytes32 voxelTypeId,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal returns (bytes32[] memory) {
    bytes32[] memory changedEntities = new bytes32[](neighbourEntityIds.length + 1);

    bytes32 baseVoxelTypeId = VoxelTypeRegistry.getBaseVoxelTypeId(IStore(REGISTRY_ADDRESS), voxelTypeId);
    while(baseVoxelTypeId != voxelTypeId){
      bytes32[] memory insideChangedEntityIds = voxelRunInteraction(callerAddress, baseVoxelTypeId, interactEntity, neighbourEntityIds, childEntityIds, parentEntity); // recursive, so we get the entire stack of russian dolls

      for (uint256 i = 0; i < insideChangedEntityIds.length; i++) {
        if (changedEntities[i] == 0) {
          changedEntities[i] = insideChangedEntityIds[i];
        }
      }
    }
    bytes4 interactionSelector = CAVoxelConfig.getInteractionSelector(baseVoxelTypeId);
    bytes memory returnData = safeCall(
        _world(),
        abi.encodeWithSelector(
          interactionSelector,
          callerAddress,
          interactEntity,
          neighbourEntityIds,
          childEntityIds,
          parentEntity
        ),
        "voxel interaction selector"
    );

    (bytes32 changedCenterEntityId, bytes32[] memory changedNeighbourEntityIds) = abi.decode(
        returnData,
        (bytes32, bytes32[])
    );

    if (changedEntities[0] == 0) {
      changedEntities[0] = changedCenterEntityId;
    }

    for (uint256 i = 0; i < changedNeighbourEntityIds.length; i++) {
      if (changedEntities[i + 1] == 0) {
        changedEntities[i + 1] = changedNeighbourEntityIds[i];
      }
    }

    return changedEntities;
  }

  function runInteraction(
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32[] memory changedEntities) {
    address callerAddress = _msgSender();
    require(hasKey(CAVoxelTypeTableId, CAVoxelType.encodeKeyTuple(callerAddress, interactEntity)), "Entity does not exist");
    bytes32 voxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, interactEntity);

    changedEntities = voxelRunInteraction(
      callerAddress,
      voxelTypeId,
      interactEntity,
      neighbourEntityIds,
      childEntityIds,
      parentEntity
    );

    // Update voxel types after interaction
    for (uint256 i = 0; i < changedEntities.length; i++) {
      bytes32 changedEntity = changedEntities[i];
      if (changedEntity != 0) {
        bytes32 changedVoxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, changedEntity);
        uint32 scale = VoxelTypeRegistry.getScale(IStore(REGISTRY_ADDRESS), changedVoxelTypeId);
        bytes32 voxelVariantId = getVoxelVariant(
          changedVoxelTypeId,
          changedEntity,
          getNeighbourEntitiesFromCaller(callerAddress, scale, changedEntity),
          getChildEntitiesFromCaller(callerAddress, scale, changedEntity),
          getParentEntityFromCaller(callerAddress, scale, changedEntity)
        );
        CAVoxelType.set(callerAddress, changedEntity, changedVoxelTypeId, voxelVariantId);
      }
    }

    return changedEntities;
  }

  function activateVoxel(bytes32 entity) public returns (string memory) {
    address callerAddress = _msgSender();
    bytes32 voxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, entity);
    bytes4 voxelActivateSelector = CAVoxelConfig.getActivateSelector(voxelTypeId);
    bytes memory returnData = safeCall(
      _world(),
      abi.encodeWithSelector(voxelActivateSelector, callerAddress, entity),
      "voxel activate"
    );
    return abi.decode(returnData, (string));
  }
}
