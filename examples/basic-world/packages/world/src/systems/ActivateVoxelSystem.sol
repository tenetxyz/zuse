// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { ActivateEvent } from "@tenet-base-world/src/prototypes/ActivateEvent.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";

contract ActivateVoxelSystem is ActivateEvent {
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
    return IWorld(_world()).activateVoxelType(voxelTypeId, coord, runEventOnChildren, runEventOnParent, eventData);
  }

  // Called by users
  function activate(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes4 interactionSelector
  ) public override returns (VoxelEntity memory) {
    return super.activate(voxelTypeId, coord, interactionSelector);
  }

  // Called by CA
  function activateVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool activateChildren,
    bool activateParent,
    bytes memory eventData
  ) public override returns (VoxelEntity memory) {
    return super.runEventHandler(voxelTypeId, coord, activateChildren, activateParent, eventData);
  }
}