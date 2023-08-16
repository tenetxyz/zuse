// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { ActivateEvent } from "../prototypes/ActivateEvent.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelCoord } from "../Types.sol";

contract ActivateVoxelSystem is ActivateEvent {
  function callEventHandler(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent,
    bytes memory eventData
  ) internal override returns (uint32, bytes32) {
    return IWorld(_world()).activateBodyType(bodyTypeId, coord, runEventOnChildren, runEventOnParent, eventData);
  }

  // Called by users
  function activate(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bytes4 interactionSelector
  ) public override returns (uint32, bytes32) {
    return super.activate(bodyTypeId, coord, interactionSelector);
  }

  // Called by CA
  function activateBodyType(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bool activateChildren,
    bool activateParent,
    bytes memory eventData
  ) public override returns (uint32, bytes32) {
    return super.runEventHandler(bodyTypeId, coord, activateChildren, activateParent, eventData);
  }
}
