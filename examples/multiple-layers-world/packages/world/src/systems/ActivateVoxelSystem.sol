// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { ActivateEvent } from "@tenet-base-world/src/prototypes/ActivateEvent.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { ActivateWorldEventData } from "@tenet-world/src/Types.sol";

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
  function activateWithAgent(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    VoxelEntity memory agentEntity,
    bytes4 interactionSelector
  ) public returns (VoxelEntity memory) {
    ActivateWorldEventData memory activateEventData = ActivateWorldEventData({
      agentEntity: agentEntity
    });
    return activate(voxelTypeId, coord, abi.encode(ActivateEventData({
      worldData: abi.encode(activateEventData),
      interactionSelector: interactionSelector
    })));
  }

  function activateVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool activateChildren,
    bool activateParent,
    bytes memory eventData
  ) internal override returns (VoxelEntity memory) {
    return super.runEventHandler(voxelTypeId, coord, activateChildren, activateParent, eventData);
  }
}
