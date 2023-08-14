// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { Event } from "./Event.sol";
import { VoxelCoord, BuildEventData } from "../Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { WorldConfig, WorldConfigTableId, OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { calculateChildCoords, getEntityAtCoord, calculateParentCoord } from "../Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { AirVoxelVariantID } from "@tenet-base-ca/src/Constants.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { voxelSpawned } from "@tenet-registry/src/Utils.sol";

abstract contract BuildEvent is Event {
  // Called by users
  function build(
    uint32 scale,
    bytes32 entity,
    VoxelCoord memory coord,
    bytes4 mindSelector
  ) public virtual returns (uint32, bytes32);

  // Called by CA
  function buildVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool buildChildren,
    bool buildParent,
    bytes memory eventData
  ) public virtual returns (uint32, bytes32) {
    (uint32 scale, bytes32 eventVoxelEntity) = super.runEventHandler(
      voxelTypeId,
      coord,
      buildChildren,
      buildParent,
      eventData
    );
    voxelSpawned(REGISTRY_ADDRESS, voxelTypeId);
    return (scale, eventVoxelEntity);
  }

  function preEvent(bytes32 voxelTypeId, VoxelCoord memory coord, bytes memory eventData) internal override {
    IWorld(_world()).approveBuild(tx.origin, voxelTypeId, coord);
  }

  function postEvent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes memory eventData
  ) internal override {}

  function runEventHandlerForParent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes memory eventData
  ) internal override {
    buildParentVoxel(scale, eventVoxelEntity, coord, eventData);
  }

  function runEventHandlerForIndividualChildren(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes32 childVoxelTypeId,
    VoxelCoord memory childCoord,
    bytes memory eventData
  ) internal override {
    if (childVoxelTypeId != 0) {
      runEventHandler(childVoxelTypeId, childCoord, true, false, eventData);
    }
  }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes memory eventData
  ) internal override {
    BuildEventData memory buildEventData = abi.decode(eventData, (BuildEventData));
    // Enter World
    IWorld(_world()).enterCA(caAddress, scale, voxelTypeId, buildEventData.mindSelector, coord, eventVoxelEntity);
  }

  function postRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    uint32 scale,
    bytes32 eventVoxelEntity,
    bytes memory eventData
  ) internal override {}

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
        if (siblingEntity != 0 && VoxelType.getVoxelVariantId(scale, siblingEntity) != AirVoxelVariantID) {
          return false;
        }
      }
    }
    return true;
  }

  function buildParentVoxel(
    uint32 buildScale,
    bytes32 buildVoxelEntity,
    VoxelCoord memory coord,
    bytes memory eventData
  ) internal virtual {
    // Calculate childVoxelTypes
    VoxelCoord memory parentVoxelCoord = calculateParentCoord(2, coord);
    VoxelCoord[] memory eightBlockVoxelCoords = calculateChildCoords(2, parentVoxelCoord);
    bytes32[] memory existingChildVoxelTypes = new bytes32[](8);
    uint32 existingCount = 0;
    for (uint8 i = 0; i < 8; i++) {
      bytes32 siblingEntity = getEntityAtCoord(buildScale, eightBlockVoxelCoords[i]);
      if (siblingEntity != 0) {
        existingChildVoxelTypes[i] = VoxelType.getVoxelTypeId(buildScale, siblingEntity);
        existingCount += 1;
      }
    }

    // Check if parent is there, and build if there
    bytes32[][] memory worldVoxelTypeKeys = getKeysInTable(WorldConfigTableId);
    for (uint256 i = 0; i < worldVoxelTypeKeys.length; i++) {
      bytes32 worldVoxelTypeId = worldVoxelTypeKeys[i][0];
      VoxelTypeRegistryData memory voxelTypeData = VoxelTypeRegistry.get(IStore(REGISTRY_ADDRESS), worldVoxelTypeId);
      if (voxelTypeData.scale == buildScale + 1) {
        bool hasSameSchema = hasSameVoxelTypeSchema(
          buildScale,
          voxelTypeData.schemaVoxelTypeIds,
          existingChildVoxelTypes,
          eightBlockVoxelCoords
        );

        if (hasSameSchema) {
          (uint32 parentScale, bytes32 parentVoxelEntity) = super.runEventHandlerHelper(
            worldVoxelTypeId,
            parentVoxelCoord,
            false,
            abi.encode(BuildEventData({ mindSelector: bytes4(0) })) // TODO: which mind to use for the parent?
          );
          buildParentVoxel(parentScale, parentVoxelEntity, parentVoxelCoord, eventData);
          break;
        }
      }
    }
  }
}
