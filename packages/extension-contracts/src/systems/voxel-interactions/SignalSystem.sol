// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelInteraction } from "../../prototypes/VoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Signal, SignalData, InvertedSignalData, InvertedSignal, SignalSource } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { registerExtension, getOppositeDirection, entityIsSignal, entityIsSignalSource, entityIsInvertedSignal } from "../../Utils.sol";

contract SignalSystem is VoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    registerExtension(world, "SignalSystem", IWorld(world).extension_SignalSystem_eventHandler.selector);
  }

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view override returns (bool) {
    return entityIsSignal(entityId, callerNamespace);
  }

  function runInteraction(
    bytes16 callerNamespace,
    bytes32 signalEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    SignalData memory signalData = Signal.get(callerNamespace, signalEntity);
    changedEntity = false;

    bool compareIsSignalSource = entityIsSignalSource(compareEntity, callerNamespace);
    bool compareIsActiveSignal = entityIsSignal(compareEntity, callerNamespace);
    if (compareIsActiveSignal) {
      SignalData memory compareSignalData = Signal.get(callerNamespace, compareEntity);
      compareIsActiveSignal =
        compareSignalData.isActive &&
        compareSignalData.direction != getOppositeDirection(compareBlockDirection);
    }
    bool compareIsActiveInvertedSignal = entityIsInvertedSignal(compareEntity, callerNamespace);
    if (compareIsActiveInvertedSignal) {
      InvertedSignalData memory compareInvertedSignalData = InvertedSignal.get(callerNamespace, compareEntity);
      compareIsActiveInvertedSignal = compareInvertedSignalData.isActive;
    }

    if (signalData.isActive) {
      // if we're active and the source direction is the same as the compare block direction
      // and if the compare entity is not active, we should become inactive
      if (signalData.direction == compareBlockDirection) {
        if (!compareIsSignalSource && !compareIsActiveSignal && !compareIsActiveInvertedSignal) {
          signalData.isActive = false;
          signalData.direction = BlockDirection.None;
          Signal.set(callerNamespace, signalEntity, signalData);
          changedEntity = true;
        }
      }
    } else {
      // if we're not active, and the compare entity is active, we should become active
      // compare entity could be a signal source, or it could be an active signal
      if (compareIsSignalSource || compareIsActiveSignal || compareIsActiveInvertedSignal) {
        signalData.isActive = true;
        signalData.direction = compareBlockDirection;
        Signal.set(callerNamespace, signalEntity, signalData);
        changedEntity = true;
      }
    }

    return changedEntity;
  }

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public override returns (bytes32[] memory) {
    return super.eventHandler(centerEntityId, neighbourEntityIds);
  }
}
