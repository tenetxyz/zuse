// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { WorldConfig, Position, PositionTableId, VoxelType, VoxelTypeTableId, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelCoord } from "../Types.sol";
import { calculateChildCoords, getEntityAtCoord, positionDataToVoxelCoord } from "../Utils.sol";

abstract contract ActivateEvent is System {
  function activateVoxel(bytes32 voxelTypeId, VoxelCoord memory coord) public virtual {
    IWorld(_world()).approveActivate(tx.origin, voxelTypeId, coord);

    require(IWorld(_world()).isVoxelTypeAllowed(voxelTypeId), "BuildSystem: Voxel type not allowed in this world");
    VoxelTypeRegistryData memory voxelTypeData = VoxelTypeRegistry.get(IStore(REGISTRY_ADDRESS), voxelTypeId);
    uint32 scale = voxelTypeData.scale;
    address caAddress = WorldConfig.get(voxelTypeId);
    bytes32 voxelToActivate = getEntityAtCoord(scale, coord);
    require(voxelToActivate != 0, "ActivateEvent: Voxel to activate does not exist");

    if (scale > 1) {
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
        activateVoxel(childVoxelTypeIds[i], eightBlockVoxelCoords[i]);
      }
    }

    IWorld(_world()).runCA(caAddress, scale, voxelToActivate);

    // Enter World
    IWorld(_world()).activateCA(caAddress, scale, voxelToActivate);
  }
}
