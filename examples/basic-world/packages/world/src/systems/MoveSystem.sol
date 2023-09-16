// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { MoveEvent } from "@tenet-base-world/src/prototypes/MoveEvent.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { MoveEventData } from "@tenet-base-world/src/Types.sol";
import { MoveWorldEventData } from "@tenet-world/src/Types.sol";

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
    return IWorld(_world()).moveVoxelType(voxelTypeId, coord, runEventOnChildren, runEventOnParent, eventData);
  }

   // Called by users
  function moveWithAgent(
    bytes32 voxelTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    VoxelEntity memory agentEntity,
    bytes4 mindSelector
  ) public returns (VoxelEntity memory) {
    MoveWorldEventData memory moveWorldEventData = MoveWorldEventData({
      agentEntity: agentEntity
    });
    return move(voxelTypeId, newCoord, abi.encode
    (MoveEventData({
      oldCoord: oldCoord,
      worldData: abi.encode(moveWorldEventData)
    })));
  }

  function moveVoxelType(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bool moveChildren,
    bool moveParent,
    bytes memory eventData
  ) internal override returns (VoxelEntity memory, VoxelEntity memory) {
    return super.moveVoxelType(voxelTypeId, coord, moveChildren, moveParent, eventData);
  }
}