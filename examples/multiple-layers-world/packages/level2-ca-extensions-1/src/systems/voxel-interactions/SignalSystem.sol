// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { SingleVoxelInteraction } from "@tenet-base-ca/src/prototypes/SingleVoxelInteraction.sol";
import { BlockDirection } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { Signal, SignalData, InvertedSignal, InvertedSignalData, Generator } from "@tenet-level2-ca-extensions-1/src/codegen/Tables.sol";
import { entityIsSignal, entityIsSignalSource, entityIsInvertedSignal, entityIsGenerator } from "@tenet-level2-ca-extensions-1/src/InteractionUtils.sol";

contract SignalSystem is SingleVoxelInteraction {
  function runSingleInteraction(
    address callerAddress,
    bytes32 signalEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    SignalData memory signalData = Signal.get(callerAddress, signalEntity);
    changedEntity = false;

    bool compareIsSignalSource = entityIsSignalSource(callerAddress, compareEntity);
    bool compareIsActiveGenerator = entityIsGenerator(callerAddress, compareEntity) &&
      Generator.get(callerAddress, compareEntity).genRate > 0;
    bool compareIsActiveSignal = entityIsSignal(callerAddress, compareEntity);
    if (compareIsActiveSignal) {
      SignalData memory compareSignalData = Signal.get(callerAddress, compareEntity);
      compareIsActiveSignal =
        compareSignalData.isActive &&
        compareSignalData.direction != getOppositeDirection(compareBlockDirection);
    }
    bool compareIsActiveInvertedSignal = entityIsInvertedSignal(callerAddress, compareEntity);
    if (compareIsActiveInvertedSignal) {
      InvertedSignalData memory compareInvertedSignalData = InvertedSignal.get(callerAddress, compareEntity);
      compareIsActiveInvertedSignal = compareInvertedSignalData.isActive;
    }

    if (signalData.isActive) {
      // if we're active and the source direction is the same as the compare block direction
      // and if the compare entity is not active, we should become inactive
      if (signalData.direction == compareBlockDirection) {
        if (
          !compareIsActiveGenerator &&
          !compareIsSignalSource &&
          !compareIsActiveSignal &&
          !compareIsActiveInvertedSignal
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
      if (compareIsSignalSource || compareIsActiveSignal || compareIsActiveInvertedSignal || compareIsActiveGenerator) {
        signalData.isActive = true;
        signalData.direction = compareBlockDirection;
        Signal.set(callerAddress, signalEntity, signalData);
        changedEntity = true;
      }
    }

    return (changedEntity, entityData);
  }

  function eventHandlerSignal(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }

  function neighbourEventHandlerSignal(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public returns (bool, bytes memory) {
    return super.neighbourEventHandler(callerAddress, neighbourEntityId, centerEntityId);
  }
}
