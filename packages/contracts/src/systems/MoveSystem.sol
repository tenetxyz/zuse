// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { MoveEvent } from "../prototypes/MoveEvent.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

contract MoveSystem is MoveEvent {
  function callEventHandler(
    bytes32 bodyTypeId,
    VoxelCoord memory coord,
    bool runEventOnChildren,
    bool runEventOnParent,
    bytes memory eventData
  ) internal override returns (uint32, bytes32) {
    revert("Move can only be called by CA's");
  }

  // Called by CA's
  function moveBodyType(
    bytes32 bodyTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bool moveChildren,
    bool moveParent
  ) public override returns (uint32, bytes32, bytes32) {
    return super.moveBodyType(bodyTypeId, oldCoord, newCoord, moveChildren, moveParent);
  }
}
