// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { BuildEvent } from "../prototypes/BuildEvent.sol";
import { VoxelCoord } from "../Types.sol";
import { OwnedBy, VoxelType, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS } from "@tenet-contracts/src/Constants.sol";

contract BuildSystem is System {
  // Called by CA's
  function moveVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bool moveChildren,
    bool moveParent
  ) public returns (uint32, bytes32) {
    require(IWorld(_world()).isCAAllowed(_msgSender()), "Not allowed to run event handler. Must be CA");

    (uint32 scale, bytes32 eventVoxelEntity) = runMoveEventHandlerHelper(voxelTypeId, oldCoord, newCoord, moveChildren);

    if (moveParent) {
      // runEventHandlerForParent(voxelTypeId, coord, scale, eventVoxelEntity);
    }

    return (scale, eventVoxelEntity);
  }

  function runMoveEventHandlerHelper(
    bytes32 voxelTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bool runEventOnChildren
  ) internal virtual returns (uint32, bytes32) {
    require(IWorld(_world()).isVoxelTypeAllowed(voxelTypeId), "Voxel type not allowed in this world");
    VoxelTypeRegistryData memory voxelTypeData = VoxelTypeRegistry.get(IStore(REGISTRY_ADDRESS), voxelTypeId);
    address caAddress = WorldConfig.get(voxelTypeId);

    uint32 scale = voxelTypeData.scale;

    bytes32 oldVoxelEntity = getEntityAtCoord(scale, oldCoord);
    require(uint256(oldVoxelEntity) != 0, "No voxel entity at old coord");
    bytes32 newVoxelEntity = getEntityAtCoord(scale, newCoord);
    if (uint256(newVoxelEntity) == 0) {
      newVoxelEntity = getUniqueEntity();
      Position.set(scale, newVoxelEntity, newCoord.x, newCoord.y, newCoord.z);
    }

    if (runEventOnChildren && scale > 1) {
      // Read the ChildTypes in this CA address
      bytes32[] memory childVoxelTypeIds = voxelTypeData.childVoxelTypeIds;
      // TODO: Make this general by using cube root
      require(childVoxelTypeIds.length == 8, "Invalid length of child voxel type ids");
      // TODO: move this to a library
      VoxelCoord[] memory eightBlockVoxelCoords = calculateChildCoords(2, oldCoord);
      VoxelCoord[] memory newEightBlockVoxelCoords = calculateChildCoords(2, newCoord);
      for (uint8 i = 0; i < 8; i++) {
        bytes32 childVoxelEntity = getEntityAtCoord(scale - 1, eightBlockVoxelCoords[i]);
        if (childVoxelEntity != 0) {
          moveVoxelType(
            VoxelType.getVoxelTypeId(scale - 1, childVoxelEntity),
            eightBlockVoxelCoords[i],
            newEightBlockVoxelCoords[i],
            true,
            false
          );
        }
      }
    }

    IWorld(_world()).moveCA(caAddress, scale, voxelTypeId, oldCoord, newCoord, newVoxelEntity);

    // Set voxel types
    CAVoxelTypeData memory oldCAVoxelType = CAVoxelType.get(IStore(caAddress), _world(), oldVoxelEntity);
    VoxelType.set(scale, oldVoxelEntity, oldCAVoxelType.voxelTypeId, oldCAVoxelType.voxelVariantId);
    CAVoxelTypeData memory newCAVoxelType = CAVoxelType.get(IStore(caAddress), _world(), newVoxelEntity);
    VoxelType.set(scale, newVoxelEntity, newCAVoxelType.voxelTypeId, newCAVoxelType.voxelVariantId);

    // Need to run 2 interactions because we're moving so two entities are involved
    IWorld(_world()).runCA(caAddress, scale, oldVoxelEntity);
    IWorld(_world()).runCA(caAddress, scale, newVoxelEntity);

    return (scale, newVoxelEntity);
  }
}
