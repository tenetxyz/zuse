// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { WorldConfig, OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { calculateChildCoords, getEntityAtCoord } from "../Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";

contract BuildSystem is System {
  function build(uint32 scale, bytes32 entity, VoxelCoord memory coord) public returns (uint32, bytes32) {
    // Require voxel to be owned by caller
    require(OwnedBy.get(scale, entity) == tx.origin, "voxel is not owned by player");

    VoxelTypeData memory voxelType = VoxelType.get(scale, entity);
    return buildVoxelType(voxelType.voxelTypeId, coord);
  }

  function buildVoxelTypeHelper(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool buildChildren
  ) internal returns (uint32, bytes32) {
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
        buildVoxelTypeHelper(childVoxelTypeIds[i], eightBlockVoxelCoords[i], true);
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

  // TODO: when we have a survival mode, prevent ppl from alling this function directly (since they don't need to own the voxel to call it)
  function buildVoxelType(bytes32 voxelTypeId, VoxelCoord memory coord) public returns (uint32, bytes32) {
    return buildVoxelTypeHelper(voxelTypeId, coord, true);
  }
}
