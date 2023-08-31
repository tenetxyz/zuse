// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { SingleVoxelInteraction } from "@tenet-base-ca/src/prototypes/SingleVoxelInteraction.sol";
import { BlockDirection } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { PoweredData, Powered, Signal, SignalData, PowerSignal, PowerSignalData } from "@tenet-level2-ca-extensions-1/src/codegen/Tables.sol";
import { entityIsPowered, entityIsSignal, entityIsSignalSource, entityIsPowerSignal } from "@tenet-level2-ca-extensions-1/src/InteractionUtils.sol";

contract PoweredSystem is SingleVoxelInteraction {
  function runSingleInteraction(
    address callerAddress,
    bytes32 poweredEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    PoweredData memory poweredData = Powered.get(callerAddress, poweredEntity);
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
    bool compareIsActiveSignal = entityIsSignal(callerAddress, compareEntity);
    if (compareIsActiveSignal) {
      SignalData memory compareSignalData = Signal.get(callerAddress, compareEntity);
      compareIsActiveSignal =
        compareSignalData.isActive &&
        (compareSignalData.direction == compareBlockDirection || compareBlockDirection == BlockDirection.Down);
    }
    bool compareIsActivePowerSignal = entityIsPowerSignal(callerAddress, compareEntity);
    if (compareIsActivePowerSignal) {
      PowerSignalData memory comparePowerSignalData = PowerSignal.get(callerAddress, compareEntity);
      compareIsActivePowerSignal =
        comparePowerSignalData.isActive &&
        (comparePowerSignalData.direction == compareBlockDirection || compareBlockDirection == BlockDirection.Down);
    }

    if (poweredData.isActive) {
      // if we're active and the source direction is the same as the compare block direction
      // and if the compare entity is not active, we should become inactive
      if (poweredData.direction == compareBlockDirection) {
        if (!compareIsSignalSource && !compareIsActiveSignal && !compareIsActivePowerSignal) {
          poweredData.isActive = false;
          poweredData.direction = BlockDirection.None;
          Powered.set(callerAddress, poweredEntity, poweredData);
          changedEntity = true;
        }
      }
    } else {
      // if we're not active, and the compare entity is active, we should become active
      // compare entity could be a signal source, or it could be an active signal that's in our direction or below us
      if (compareIsSignalSource || compareIsActiveSignal || compareIsActivePowerSignal) {
        poweredData.isActive = true;
        poweredData.direction = compareBlockDirection;
        Powered.set(callerAddress, poweredEntity, poweredData);
        changedEntity = true;
      }
    }

    return changedEntity;
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    return entityIsPowered(callerAddress, entityId);
  }

  function eventHandlerPowered(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
