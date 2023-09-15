// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { MoveEvent } from "@tenet-base-world/src/prototypes/MoveEvent.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";

contract MoveSystem is MoveEvent {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function callEventHandler(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent,
    bytes memory eventData
  ) internal override returns (VoxelEntity memory) {
    revert("Move can only be called by CA's");
  }

  // Called by CA's
  function moveVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bool moveChildren,
    bool moveParent
  ) public override returns (VoxelEntity memory, VoxelEntity memory) {
    return super.moveVoxelType(voxelTypeId, oldCoord, newCoord, moveChildren, moveParent);
  }
}