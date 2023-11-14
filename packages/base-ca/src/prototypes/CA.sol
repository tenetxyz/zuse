// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { VoxelTypeRegistry } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { CAPosition, CAPositionData, CAPositionTableId } from "@tenet-base-ca/src/codegen/tables/CAPosition.sol";
import { CAReversePosition, CAReversePositionData, CAReversePositionTableId } from "@tenet-base-ca/src/codegen/tables/CAReversePosition.sol";
import { CAMind, CAMindTableId } from "@tenet-base-ca/src/codegen/tables/CAMind.sol";
import { CAEntityMapping, CAEntityMappingTableId } from "@tenet-base-ca/src/codegen/tables/CAEntityMapping.sol";
import { CAEntityReverseMapping } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { CAVoxelType, CAVoxelTypeTableId } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { VoxelCoord, InteractionSelector, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, entityArrayToCAEntityArray, entityToCAEntity, caEntityArrayToEntityArray } from "@tenet-base-ca/src/Utils.sol";
import { getNeighbourEntitiesFromCaller, getChildEntitiesFromCaller, getParentEntityFromCaller, shouldRunInteractionForNeighbour } from "@tenet-base-ca/src/CallUtils.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { getEnterWorldSelector, getExitWorldSelector, getVoxelVariantSelector, getActivateSelector, getInteractionSelectors, getOnNewNeighbourSelector } from "@tenet-registry/src/Utils.sol";
import { TerrainGenType } from "@tenet-base-ca/src/Constants.sol";
import { console } from "forge-std/console.sol";

abstract contract CA is System {
  function getRegistryAddress() internal pure virtual returns (address);

  function registerCA() public virtual;

  function emptyVoxelId() internal pure virtual returns (bytes32) {}

  function callVoxelEnterWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) internal virtual;

  function callVoxelExitWorld(bytes32 voxelTypeId, VoxelCoord memory coord, bytes32 caEntity) internal virtual;

  function callGetVoxelVariant(
    bytes32 voxelTypeId,
    bytes32 caEntity,
    bytes32[] memory caNeighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal virtual returns (bytes32);

  function getTerrainVoxelId(VoxelCoord memory coord) public virtual returns (bytes32);

  function terrainGen(
    address callerAddress,
    TerrainGenType terrainGenType,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes32 entity
  ) internal virtual returns (bytes32) {
    bytes32 terrainVoxelTypeId = getTerrainVoxelId(coord);
    if (terrainGenType == TerrainGenType.Mine) {
      require(terrainVoxelTypeId != emptyVoxelId() && terrainVoxelTypeId == voxelTypeId, "invalid terrain voxel type");
    } else if (terrainGenType == TerrainGenType.Build) {
      require(terrainVoxelTypeId == emptyVoxelId() || terrainVoxelTypeId == voxelTypeId, "invalid terrain voxel type");
    } else if (terrainGenType == TerrainGenType.Move) {
      require(terrainVoxelTypeId == emptyVoxelId(), "cannot move to non-empty terrain");
    }
    require(!CAEntityMapping.getHasValue(callerAddress, entity), "Entity exists");
    CAPosition.set(callerAddress, entity, CAPositionData({ x: coord.x, y: coord.y, z: coord.z, hasValue: true }));
    CAReversePosition.set(coord.x, coord.y, coord.z, callerAddress, CAReversePositionData({ entity: entity, hasValue: true }));
    bytes32 caEntity = getUniqueEntity();
    if (terrainGenType != TerrainGenType.Move) {
      CAEntityMapping.set(callerAddress, entity, caEntity, true);
      CAEntityReverseMapping.set(caEntity, callerAddress, entity, true);
    }
    return caEntity;
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
    if (uint256(existingEntity) != 0) {
      require(
        CAVoxelType.get(callerAddress, existingEntity).voxelTypeId == emptyVoxelId(),
        "EnterWorld: This position is already occupied by another voxel"
      );
      caEntity = entityToCAEntity(callerAddress, entity);
    } else {
      caEntity = terrainGen(callerAddress, TerrainGenType.Build, voxelTypeId, coord, entity);
    }
    CAMind.set(caEntity, voxelTypeId, mindSelector, true);

    bytes32[] memory caNeighbourEntityIds = entityArrayToCAEntityArray(callerAddress, neighbourEntityIds);

    callVoxelEnterWorld(voxelTypeId, coord, caEntity);

    bytes32 voxelVariantId = callGetVoxelVariant(
      voxelTypeId,
      caEntity,
      caNeighbourEntityIds,
      childEntityIds,
      parentEntity
    );
    CAVoxelType.set(callerAddress, entity, voxelTypeId, voxelVariantId, true);
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
    if (!CAPosition.getHasValue(callerAddress, entity)) {
      terrainGen(callerAddress, TerrainGenType.Mine, voxelTypeId, coord, entity);
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
    CAVoxelType.set(callerAddress, entity, emptyVoxelId(), airVoxelVariantId, true);

    callVoxelExitWorld(voxelTypeId, coord, caEntity);

    CAMind.set(caEntity, voxelTypeId, bytes4(0), true); // emoty voxel has no mind
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
      CAVoxelType.set(callerAddress, oldEntity, emptyVoxelId(), airVoxelVariantId, true);
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
      newCAEntity = terrainGen(callerAddress, TerrainGenType.Move, voxelTypeId, newCoord, newEntity);
      // TODO: should there be a mind for this new entity?
      CAMind.set(newCAEntity, voxelTypeId, bytes4(0), true);
    }

    // Update CA entity mapping from old to new
    // Note: This is the main move of the pointer
    CAEntityMapping.set(callerAddress, oldEntity, newCAEntity, true);
    CAEntityReverseMapping.set(newCAEntity, callerAddress, oldEntity, true);
    CAEntityMapping.set(callerAddress, newEntity, oldCAEntity, true);
    CAEntityReverseMapping.set(oldCAEntity, callerAddress, newEntity, true);

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
    CAVoxelType.set(callerAddress, newEntity, voxelTypeId, voxelVariantId, true);
  }

  function decodeToString(bytes memory data) external pure returns (string memory) {
    return abi.decode(data, (string));
  }

  function activateVoxel(bytes32 entity) public returns (string memory) {
    address callerAddress = _msgSender();
    bytes32 voxelTypeId = CAVoxelType.getVoxelTypeId(callerAddress, entity);
    bytes4 voxelActivateSelector = getActivateSelector(IStore(getRegistryAddress()), voxelTypeId);
    bytes32 caEntity = entityToCAEntity(callerAddress, entity);
    if (voxelActivateSelector == bytes4(0)) {
      return "no voxel activate";
    }
    (bool success, bytes memory returnData) = safeCall(
      _world(),
      abi.encodeWithSelector(voxelActivateSelector, caEntity),
      "voxel activate"
    );
    if (!success) {
      return "voxel activate failed";
    }
    try this.decodeToString(returnData) returns (string memory decodedValue) {
      return decodedValue;
    } catch {
      return "voxel activate failed";
    }
  }
}
