// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { SingleVoxelInteraction } from "@tenet-base-ca/src/prototypes/SingleVoxelInteraction.sol";
import { CAVoxelInteractionConfig, PowerSignal, PowerSignalData, PowerWire, PowerWireData, InvertedSignalData, InvertedSignal, SignalSource, Generator } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { BlockDirection } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { entityIsPowerSignal, entityIsSignalSource, entityIsInvertedSignal, entityIsGenerator } from "@tenet-level2-ca/src/InteractionUtils.sol";

contract PowerSignalSystem is SingleVoxelInteraction {
  function registerInteractionPowerSignal() public {
    address world = _world();
    CAVoxelInteractionConfig.push(IWorld(world).eventHandlerPowerSignal.selector);
  }

  function runSingleInteraction(
    address callerAddress,
    bytes32 powerSignalEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    PowerSignalData memory powerSignalData = PowerSignal.get(callerAddress, powerSignalEntity);
    PowerWireData memory powerWireData = PowerWire.get(callerAddress, powerSignalEntity);
    changedEntity = false;

    bool compareIsSignalSource = entityIsSignalSource(callerAddress, compareEntity);
    bool compareIsActiveGenerator = entityIsGenerator(callerAddress, compareEntity) &&
      Generator.get(callerAddress, compareEntity).genRate > 0;
    bool compareIsActivePowerSignal = entityIsPowerSignal(callerAddress, compareEntity);
    if (compareIsActivePowerSignal) {
      PowerSignalData memory comparePowerSignalData = PowerSignal.get(callerAddress, compareEntity);
      compareIsActivePowerSignal =
        comparePowerSignalData.isActive &&
        comparePowerSignalData.direction != getOppositeDirection(compareBlockDirection);
    }
    bool compareIsActiveInvertedSignal = entityIsInvertedSignal(callerAddress, compareEntity);
    if (compareIsActiveInvertedSignal) {
      InvertedSignalData memory compareInvertedSignalData = InvertedSignal.get(callerAddress, compareEntity);
      compareIsActiveInvertedSignal = compareInvertedSignalData.isActive;
    }

    if (powerSignalData.isActive) {
      // if we're active and the source direction is the same as the compare block direction
      // and if the compare entity is not active, we should become inactive
      if (powerSignalData.direction == compareBlockDirection) {
        if (
          !compareIsActiveGenerator &&
          !compareIsSignalSource &&
          !compareIsActivePowerSignal &&
          !compareIsActiveInvertedSignal
        ) {
          powerSignalData.isActive = false;
          powerSignalData.direction = BlockDirection.None;
          PowerSignal.set(callerAddress, powerSignalEntity, powerSignalData);
          changedEntity = true;
        }
      }

      if (powerWireData.isBroken) {
        powerSignalData.isActive = false;
        powerSignalData.direction = BlockDirection.None;
        PowerSignal.set(callerAddress, powerSignalEntity, powerSignalData);
        changedEntity = true;
      }
    } else {
      // if we're not active, and the compare entity is active, we should become active
      // compare entity could be a signal source, or it could be an active signal
      if (
        !powerWireData.isBroken &&
        (compareIsActiveGenerator ||
          compareIsSignalSource ||
          compareIsActivePowerSignal ||
          compareIsActiveInvertedSignal)
      ) {
        powerSignalData.isActive = true;
        powerSignalData.direction = compareBlockDirection;
        PowerSignal.set(callerAddress, powerSignalEntity, powerSignalData);
        changedEntity = true;
      }
    }

    return changedEntity;
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    return entityIsPowerSignal(callerAddress, entityId);
  }

  function eventHandlerPowerSignal(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
