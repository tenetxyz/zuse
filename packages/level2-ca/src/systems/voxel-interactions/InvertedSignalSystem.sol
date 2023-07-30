// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { SingleVoxelInteraction } from "@tenet-base-ca/src/prototypes/SingleVoxelInteraction.sol";
import { BlockDirection } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { CAVoxelInteractionConfig, InvertedSignal, InvertedSignalData, PoweredData, Powered } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { entityIsInvertedSignal, entityIsSignal, entityIsSignalSource, entityIsPowered } from "@tenet-level2-ca/src/InteractionUtils.sol";

contract InvertedSignalSystem is SingleVoxelInteraction {
  function registerInteractionInvertedSignal() public {
    address world = _world();
    CAVoxelInteractionConfig.push(IWorld(world).eventHandlerInvertedSignal.selector);
  }

  function runSingleInteraction(
    address callerAddress,
    bytes32 invertedSignalEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    InvertedSignalData memory invertedSignalData = InvertedSignal.get(callerAddress, invertedSignalEntity);
    changedEntity = false;

    if (
      compareBlockDirection == BlockDirection.NorthEast ||
      compareBlockDirection == BlockDirection.NorthWest ||
      compareBlockDirection == BlockDirection.SouthEast ||
      compareBlockDirection == BlockDirection.SouthWest
    ) {
      return false;
    }

    bool compareIsPowered = entityIsPowered(callerAddress, compareEntity);
    PoweredData memory comparePoweredData;
    if (compareIsPowered) {
      comparePoweredData = Powered.get(callerAddress, compareEntity);
    }
    bool compareIsSignalSource = entityIsSignalSource(callerAddress, compareEntity);

    if (invertedSignalData.isActive) {
      // check if we should remain active
      // if compare is active powered and we're not the ones powering it
      // then we are now adjacent to a powered block, so we should become inactive
      if (
        compareIsPowered &&
        comparePoweredData.isActive &&
        comparePoweredData.direction != getOppositeDirection(compareBlockDirection)
      ) {
        invertedSignalData.isActive = false;
        invertedSignalData.direction = compareBlockDirection; // blocked direction
        InvertedSignal.set(callerAddress, invertedSignalEntity, invertedSignalData);
        changedEntity = true;
      }
    } else {
      // check to see if we should be active?
      // were we previously blocked by an active powered block
      if (
        invertedSignalData.direction == compareBlockDirection &&
        (!compareIsPowered || (compareIsPowered && !comparePoweredData.isActive))
      ) {
        invertedSignalData.isActive = true;
        invertedSignalData.direction = BlockDirection.None;
        InvertedSignal.set(callerAddress, invertedSignalEntity, invertedSignalData);
        changedEntity = true;
      }
    }

    return changedEntity;
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    return entityIsInvertedSignal(callerAddress, entityId);
  }

  function eventHandlerInvertedSignal(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
