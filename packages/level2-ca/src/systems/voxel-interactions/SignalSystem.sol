// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { SingleVoxelInteraction } from "@tenet-base-ca/src/prototypes/SingleVoxelInteraction.sol";
import { BlockDirection } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { CAVoxelInteractionConfig, Signal, SignalData } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { entityIsSignal, entityIsSignalSource } from "@tenet-level2-ca/src/InteractionUtils.sol";

contract SignalSystem is SingleVoxelInteraction {
  function registerInteractionSignal() public {
    address world = _world();
    CAVoxelInteractionConfig.push(IWorld(world).eventHandlerSignal.selector);
  }

  function runSingleInteraction(
    address callerAddress,
    bytes32 signalEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    SignalData memory signalData = Signal.get(callerAddress, signalEntity);
    changedEntity = false;

    if (
      compareBlockDirection == BlockDirection.NorthEast ||
      compareBlockDirection == BlockDirection.NorthWest ||
      compareBlockDirection == BlockDirection.SouthEast ||
      compareBlockDirection == BlockDirection.SouthWest
    ) {
      return false;
    }

    bool compareIsSignalSource = entityIsSignalSource(callerAddress, compareEntity);
    // bool compareIsActiveGenerator = entityIsGenerator(compareEntity, callerAddress) &&
    //   Generator.get(callerAddress, compareEntity).genRate > 0;
    bool compareIsActiveSignal = entityIsSignal(callerAddress, compareEntity);
    if (compareIsActiveSignal) {
      SignalData memory compareSignalData = Signal.get(callerAddress, compareEntity);
      compareIsActiveSignal =
        compareSignalData.isActive &&
        compareSignalData.direction != getOppositeDirection(compareBlockDirection);
    }
    // bool compareIsActiveInvertedSignal = entityIsInvertedSignal(compareEntity, callerAddress);
    // if (compareIsActiveInvertedSignal) {
    //   InvertedSignalData memory compareInvertedSignalData = InvertedSignal.get(callerAddress, compareEntity);
    //   compareIsActiveInvertedSignal = compareInvertedSignalData.isActive;
    // }

    if (signalData.isActive) {
      // if we're active and the source direction is the same as the compare block direction
      // and if the compare entity is not active, we should become inactive
      if (signalData.direction == compareBlockDirection) {
        if (
          // !compareIsActiveGenerator &&
          !compareIsSignalSource && !compareIsActiveSignal
          // !compareIsActiveInvertedSignal
        ) {
          signalData.isActive = false;
          signalData.direction = BlockDirection.None;
          Signal.set(callerAddress, signalEntity, signalData);
          changedEntity = true;
        }
      }
    } else {
      // if we're not active, and the compare entity is active, we should become active
      // compare entity could be a signal source, or it could be an active signal
      if (compareIsSignalSource || compareIsActiveSignal) {
        signalData.isActive = true;
        signalData.direction = compareBlockDirection;
        Signal.set(callerAddress, signalEntity, signalData);
        changedEntity = true;
      }
    }

    return changedEntity;
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    return entityIsSignal(callerAddress, entityId);
  }

  function eventHandlerSignal(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}