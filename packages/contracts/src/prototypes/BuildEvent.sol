// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../Types.sol";
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

abstract contract BuildEvent is System {
  // Called by users
  function build(bytes32 voxelTypeId, VoxelCoord memory coord) public virtual returns (uint32, bytes32) {
    IWorld(_world()).approveBuild(tx.origin, voxelTypeId, coord);
    return IWorld(_world()).buildVoxelType(voxelTypeId, coord, true, true);
  }

  function buildVoxelTypeHelper(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool buildChildren
  ) internal virtual returns (uint32, bytes32) {
    require(IWorld(_world()).isVoxelTypeAllowed(voxelTypeId), "BuildSystem: Voxel type not allowed in this world");
    VoxelTypeRegistryData memory voxelTypeData = VoxelTypeRegistry.get(IStore(REGISTRY_ADDRESS), voxelTypeId);
    address caAddress = WorldConfig.get(voxelTypeId);

    uint32 scale = voxelTypeData.scale;
    if (buildChildren && scale > 1) {
      // Read the ChildTypes in this CA address
      bytes32[] memory childVoxelTypeIds = voxelTypeData.childVoxelTypeIds;
      // TODO: Make this general by using cube root
      require(childVoxelTypeIds.length == 8, "Invalid length of child voxel type ids");
      // TODO: move this to a library
      VoxelCoord[] memory eightBlockVoxelCoords = calculateChildCoords(2, coord);
      for (uint8 i = 0; i < 8; i++) {
        if (childVoxelTypeIds[i] == 0) {
          continue;
        }
        buildVoxelType(childVoxelTypeIds[i], eightBlockVoxelCoords[i], true, false);
      }
    }

    // After we've built all the child types, we can build the parent type
    bytes32 voxelToBuild = getEntityAtCoord(scale, coord);
    if (uint256(voxelToBuild) == 0) {
      voxelToBuild = getUniqueEntity();
      // Set Position
      Position.set(scale, voxelToBuild, coord.x, coord.y, coord.z);
    }

    // Enter World
    IWorld(_world()).enterCA(caAddress, scale, voxelTypeId, coord, voxelToBuild);

    // Set initial voxel type
    CAVoxelTypeData memory entityCAVoxelType = CAVoxelType.get(IStore(caAddress), _world(), voxelToBuild);
    VoxelType.set(scale, voxelToBuild, entityCAVoxelType.voxelTypeId, entityCAVoxelType.voxelVariantId);

    IWorld(_world()).runCA(caAddress, scale, voxelToBuild);

    return (scale, voxelToBuild);
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
        if (siblingEntity != 0 && VoxelType.getVoxelVariantId(scale, siblingEntity) != AirVoxelVariantID) {
          return false;
        }
      }
    }
    return true;
  }

  function buildParentVoxel(uint32 buildScale, bytes32 buildVoxelEntity, VoxelCoord memory coord) internal virtual {
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
          (uint32 parentScale, bytes32 parentVoxelEntity) = buildVoxelTypeHelper(
            worldVoxelTypeId,
            parentVoxelCoord,
            false
          );
          buildParentVoxel(parentScale, parentVoxelEntity, parentVoxelCoord);
          break;
        }
      }
    }
  }

  // Called by CA's
  function buildVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool buildChildren,
    bool buildParent
  ) public virtual returns (uint32, bytes32) {
    require(
      _msgSender() == _world() || IWorld(_world()).isCAAllowed(_msgSender()),
      "BuildSystem: Not allowed to build"
    );
    (uint32 buildScale, bytes32 buildVoxelEntity) = buildVoxelTypeHelper(voxelTypeId, coord, buildChildren);

    if (buildParent) {
      buildParentVoxel(buildScale, buildVoxelEntity, coord);
    }

    return (buildScale, buildVoxelEntity);
  }
}
