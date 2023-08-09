// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { ActivateEvent } from "../prototypes/ActivateEvent.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelCoord } from "../Types.sol";

contract ActivateVoxelSystem is ActivateEvent {
  function callEventHandler(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent
  ) internal override returns (uint32, bytes32) {
    return IWorld(_world()).activateVoxelType(voxelTypeId, coord, runEventOnChildren, runEventOnParent);
  }

  // Called by users
  function activate(bytes32 voxelTypeId, VoxelCoord memory coord) public override returns (uint32, bytes32) {
    return super.activate(voxelTypeId, coord);
  }

  // Called by CA
  function activateVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool activateChildren,
    bool activateParent
  ) public override returns (uint32, bytes32) {
    return super.runEventHandler(voxelTypeId, coord, activateChildren, activateParent);
  }
}
