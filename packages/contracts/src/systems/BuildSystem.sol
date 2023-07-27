// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { CAConfig, OwnedBy, Position, PositionTableId, VoxelType, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { calculateChildCoords, getEntityAtCoord } from "../Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { addressToEntityKey } from "@tenet-utils/src/Utils.sol";
import { enterWorld } from "@tenet-base-ca/src/CallUtils.sol";

contract BuildSystem is System {
  function build(uint32 scale, bytes32 entity, VoxelCoord memory coord) public returns (bytes32) {
    // Require voxel to be owned by caller
    require(OwnedBy.get(scale, entity) == tx.origin, "voxel is not owned by player");

    VoxelTypeData memory voxelType = VoxelType.get(scale, entity);
    return buildVoxelType(voxelType.voxelTypeId, coord);
  }

  // TODO: when we have a survival mode, prevent ppl from alling this function directly (since they don't need to own the voxel to call it)
  function buildVoxelType(bytes32 voxelTypeId, VoxelCoord memory coord) public returns (bytes32) {
    require(IWorld(_world()).isVoxelTypeAllowed(voxelTypeId), "Voxel type not allowed in this world");
    VoxelTypeRegistryData memory voxelTypeData = VoxelTypeRegistry.get(IStore(REGISTRY_ADDRESS), voxelTypeId);
    address caAddress = CAConfig.get(voxelTypeId);

    uint32 scale = voxelTypeData.scale;
    if (scale > 1) {
      // Read the ChildTypes in this CA address
      bytes32[] memory childVoxelTypeIds = voxelTypeData.childVoxelTypeIds;
      // TODO: Make this general by using cube root
      require(childVoxelTypeIds.length == 8, "Invalid length of child voxel type ids");
      // TODO: move this to a library
      VoxelCoord[] memory eightBlockVoxelCoords = calculateChildCoords(scale, coord);
      for (uint8 i = 0; i < 8; i++) {
        buildVoxelType(childVoxelTypeIds[i], eightBlockVoxelCoords[i]);
      }
    }

    // After we've built all the child types, we can build the parent type
    bytes32 voxelToBuild = getEntityAtCoord(scale, coord);
    if (voxelToBuild == 0) {
      voxelToBuild = getUniqueEntity();
      // Set Position
      Position.set(scale, voxelToBuild, coord.x, coord.y, coord.z);
    }

    // Enter World
    enterWorld(caAddress, voxelTypeId, coord, voxelToBuild);

    // Set initial voxel type
    CAVoxelTypeData memory entityCAVoxelType = CAVoxelType.get(IStore(caAddress), _world(), voxelToBuild);
    VoxelType.set(scale, voxelToBuild, entityCAVoxelType.voxelTypeId, entityCAVoxelType.voxelVariantId);

    IWorld(_world()).runCA(caAddress, scale, voxelToBuild);

    return voxelToBuild;
  }
}
