// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { SingleVoxelInteraction } from "@tenet-base-ca/src/prototypes/SingleVoxelInteraction.sol";
import { BlockDirection, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";

contract MoveForwardSystem is SingleVoxelInteraction {
  function runSingleInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    changedEntity = false;
    VoxelCoord memory baseCoord = getCAEntityPositionStrict(IStore(_world()), interactEntity);
    VoxelCoord memory newCoord = VoxelCoord({ x: baseCoord.x + 1, y: baseCoord.y, z: baseCoord.z });
    bytes32 entityType = getCAVoxelType(interactEntity);

    IWorld(_world()).moveCAWorld(callerAddress, entityType, baseCoord, newCoord);

    return changedEntity;
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    return true;
  }

  function eventHandlerMoveForward(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
