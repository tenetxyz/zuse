// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { CAPosition, CAPositionData, CAPositionTableId } from "@tenet-base-ca/src/codegen/tables/CAPosition.sol";
import { CAVoxelInteractionConfig } from "@tenet-base-ca/src/codegen/tables/CAVoxelInteractionConfig.sol";
import { CAVoxelConfig, CAVoxelConfigTableId } from "@tenet-base-ca/src/codegen/tables/CAVoxelConfig.sol";
import { CAVoxelType } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord } from "@tenet-base-ca/src/Utils.sol";
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

  function enterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) public {
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

    bytes4 voxelEnterWorldSelector = CAVoxelConfig.getEnterWorldSelector(voxelTypeId);
    safeCall(
      _world(),
      abi.encodeWithSelector(voxelEnterWorldSelector, callerAddress, coord, entity),
      "voxel enter world"
    );

    bytes32 voxelVariantId = getVoxelVariant(voxelTypeId, entity, new bytes32[](0), new bytes32[](0), 0);
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

  function exitWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 entity) public {
    require(voxelTypeId != emptyVoxelId(), "can not mine air");
    address callerAddress = _msgSender();
    if (!hasKey(CAPositionTableId, CAPosition.encodeKeyTuple(callerAddress, entity))) {
      terrainGen(callerAddress, voxelTypeId, coord, entity);
    }
    // set to Air
    bytes32 airVoxelVariantId = getVoxelVariant(emptyVoxelId(), entity, new bytes32[](0), new bytes32[](0), 0);
    CAVoxelType.set(callerAddress, entity, emptyVoxelId(), airVoxelVariantId);

    bytes4 voxelExitWorldSelector = CAVoxelConfig.getExitWorldSelector(voxelTypeId);
    safeCall(
      _world(),
      abi.encodeWithSelector(voxelExitWorldSelector, callerAddress, coord, entity),
      "voxel exit world"
    );
  }

  function runInteraction(
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32[] memory changedEntities) {
    address callerAddress = _msgSender();

    changedEntities = new bytes32[](neighbourEntityIds.length + 1);

    bytes4[] memory interactionSelectors = CAVoxelInteractionConfig.get();
    for (uint256 i = 0; i < interactionSelectors.length; i++) {
      bytes4 interactionSelector = interactionSelectors[i];
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
      for (uint256 j = 0; j < changedNeighbourEntityIds.length; j++) {
        if (changedEntities[j + 1] == 0) {
          changedEntities[j + 1] = changedNeighbourEntityIds[j];
        }
      }
    }

    for (uint256 i = 0; i < changedEntities.length; i++) {
      bytes32 changedEntity = changedEntities[i];
      if (changedEntity != 0) {
        bytes32 voxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, changedEntity);
        uint32 scale = VoxelTypeRegistry.getScale(voxelTypeId);
        bytes32 voxelVariantId = getVoxelVariant(
          voxelTypeId,
          changedEntity,
          getNeighbourEntitiesFromCaller(callerAddress, scale, changedEntity),
          getChildEntitiesFromCaller(callerAddress, scale, changedEntity),
          getParentEntityFromCaller(callerAddress, scale, changedEntity)
        );
        CAVoxelType.set(callerAddress, changedEntity, voxelTypeId, voxelVariantId);
      }
    }

    return changedEntities;
  }
}
