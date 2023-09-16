// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { Event } from "@tenet-base-world/src/prototypes/Event.sol";
import { BuildEventData } from "@tenet-base-world/src/Types.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { VoxelEntity } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { WorldConfig, WorldConfigTableId } from "@tenet-base-world/src/codegen/tables/WorldConfig.sol";
import { Position, PositionTableId } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { VoxelType, VoxelTypeData } from "@tenet-base-world/src/codegen/tables/VoxelType.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { calculateChildCoords, getEntityAtCoord, calculateParentCoord } from "@tenet-base-world/src/Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { voxelSpawned } from "@tenet-registry/src/Utils.sol";

abstract contract BuildEvent is Event {
  function emptyVoxelId() internal pure virtual returns (bytes32) {}

  function build(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual returns (VoxelEntity memory) {
    VoxelEntity memory builtEntity = super.runEvent(voxelTypeId, coord, eventData);
    voxelSpawned(getRegistryAddress(), voxelTypeId);
    return builtEntity;
  }

  function preEvent(bytes32 voxelTypeId, VoxelCoord memory coord, bytes memory eventData) internal virtual override {
    IWorld(_world()).approveBuild(tx.origin, voxelTypeId, coord, eventData);
  }

  function postEvent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {}

  function runEventHandlerForParent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {
    buildParentVoxel(voxelTypeId, eventVoxelEntity, coord, eventData);
  }

  function getChildEventData(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData,
    uint8 childIdx,
    bytes32 childVoxelTypeId,
    VoxelCoord memory childCoord
  ) internal override returns (bytes memory) {
    BuildEventData memory childBuildEventData = abi.decode(eventData, (BuildEventData));
    childBuildEventData.mindSelector = bytes4(0); // TODO: which mind to use for the children?
    return abi.encode(childBuildEventData);
  }

  function runEventHandlerForIndividualChildren(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    uint8 childIdx,
    bytes32 childVoxelTypeId,
    VoxelCoord memory childCoord,
    bytes memory eventData
  ) internal virtual override {
    if (childVoxelTypeId != 0) {
      runEventHandler(
        childVoxelTypeId,
        childCoord,
        true,
        false,
        getChildEventData(voxelTypeId, coord, eventVoxelEntity, eventData, childIdx, childVoxelTypeId, childCoord)
      );
    }
  }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {
    BuildEventData memory buildEventData = abi.decode(eventData, (BuildEventData));
    // Enter World
    IWorld(_world()).enterCA(caAddress, eventVoxelEntity, voxelTypeId, buildEventData.mindSelector, coord);
  }

  function postRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {}

  function runCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal virtual override {
    IWorld(_world()).runCA(caAddress, eventVoxelEntity, bytes4(0));
  }

  function hasSameVoxelTypeSchema(
    uint32 scale,
    bytes32[] memory referenceVoxelTypeIds,
    bytes32[] memory existingVoxelTypeIds,
    VoxelCoord[] memory eightBlockVoxelCoords
  ) internal view virtual returns (bool) {
    if (referenceVoxelTypeIds.length != existingVoxelTypeIds.length) {
      return false;
    }
    for (uint256 i = 0; i < referenceVoxelTypeIds.length; i++) {
      if (referenceVoxelTypeIds[i] != 0) {
        if (referenceVoxelTypeIds[i] != existingVoxelTypeIds[i]) {
          return false;
        }
      } else {
        bytes32 siblingEntity = getEntityAtCoord(scale, eightBlockVoxelCoords[i]);
        if (siblingEntity != 0 && VoxelType.getVoxelVariantId(scale, siblingEntity) != emptyVoxelId()) {
          return false;
        }
      }
    }
    return true;
  }

  function getParentEventData(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData,
    bytes32 childVoxelTypeId,
    VoxelCoord memory childCoord
  ) internal override returns (bytes memory) {
    BuildEventData memory parentBuildEventData = abi.decode(eventData, (BuildEventData));
    // TODO: get parent agent entity
    parentBuildEventData.mindSelector = bytes4(0); // TODO: which mind to use for the parent?
    return abi.encode(parentBuildEventData);
  }

  function buildParentVoxel(
    bytes32 voxelTypeId,
    VoxelEntity memory buildVoxelEntity,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual {
    uint32 buildScale = buildVoxelEntity.scale;
    // Calculate childVoxelTypes
    VoxelCoord memory parentVoxelCoord = calculateParentCoord(2, coord);
    VoxelCoord[] memory eightBlockVoxelCoords = calculateChildCoords(2, parentVoxelCoord);
    bytes32[] memory existingChildVoxelTypes = new bytes32[](8);
    for (uint8 i = 0; i < 8; i++) {
      bytes32 siblingEntity = getEntityAtCoord(buildScale, eightBlockVoxelCoords[i]);
      if (siblingEntity != 0) {
        existingChildVoxelTypes[i] = VoxelType.getVoxelTypeId(buildScale, siblingEntity);
      }
    }

    // Check if parent is there, and build if there
    bytes32[][] memory worldVoxelTypeKeys = getKeysInTable(WorldConfigTableId);
    for (uint256 i = 0; i < worldVoxelTypeKeys.length; i++) {
      bytes32 worldVoxelTypeId = worldVoxelTypeKeys[i][0];
      VoxelTypeRegistryData memory voxelTypeData = VoxelTypeRegistry.get(
        IStore(getRegistryAddress()),
        worldVoxelTypeId
      );
      if (voxelTypeData.scale == buildScale + 1) {
        bool foundMatch = buildParentVoxelHelper(
          voxelTypeId,
          buildVoxelEntity,
          coord,
          eventData,
          voxelTypeData,
          existingChildVoxelTypes,
          eightBlockVoxelCoords,
          worldVoxelTypeId,
          parentVoxelCoord
        );
        if (foundMatch) {
          break;
        }
      }
    }
  }

  function buildParentVoxelHelper(
    bytes32 voxelTypeId,
    VoxelEntity memory buildVoxelEntity,
    VoxelCoord memory coord,
    bytes memory eventData,
    VoxelTypeRegistryData memory voxelTypeData,
    bytes32[] memory existingChildVoxelTypes,
    VoxelCoord[] memory eightBlockVoxelCoords,
    bytes32 worldVoxelTypeId,
    VoxelCoord memory parentVoxelCoord
  ) internal returns (bool) {
    uint32 buildScale = buildVoxelEntity.scale;

    bool hasSameSchema = hasSameVoxelTypeSchema(
      buildScale,
      voxelTypeData.schemaVoxelTypeIds,
      existingChildVoxelTypes,
      eightBlockVoxelCoords
    );

    if (hasSameSchema) {
      VoxelEntity memory parentVoxelEntity = super.runEventHandlerHelper(
        worldVoxelTypeId,
        parentVoxelCoord,
        false,
        getParentEventData(voxelTypeId, coord, buildVoxelEntity, eventData, worldVoxelTypeId, parentVoxelCoord)
      );
      buildParentVoxel(worldVoxelTypeId, parentVoxelEntity, parentVoxelCoord, eventData);
    }
    return hasSameSchema;
  }
}
