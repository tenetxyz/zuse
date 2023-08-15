// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { VoxelInteraction } from "@tenet-base-ca/src/prototypes/VoxelInteraction.sol";
import { BlockDirection, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { Fighters } from "@tenet-level2-ca/src/codegen/tables/Fighters.sol";

contract MoveForwardSystem is VoxelInteraction {
  function onNewNeighbour(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal override returns (bool changedEntity) {
    return false;
  }

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bool changedEntity) {
    changedEntity = false;
    VoxelCoord memory baseCoord = getCAEntityPositionStrict(IStore(_world()), interactEntity);
    VoxelCoord memory newCoord = VoxelCoord({ x: baseCoord.x + 1, y: baseCoord.y, z: baseCoord.z });
    bytes32 entityType = getCAVoxelType(interactEntity);

    IWorld(_world()).moveCAWorld(callerAddress, entityType, baseCoord, newCoord);

    return changedEntity;
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    return Fighters.get(callerAddress, entityId).hasValue;
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
