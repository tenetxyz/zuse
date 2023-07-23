// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SingleVoxelInteraction } from "@tenet-contracts/src/prototypes/SingleVoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { PowerSignal, PowerSignalData, PowerWire, PowerWireData, InvertedSignalData, InvertedSignal, SignalSource, Generator } from "@tenet-extension-contracts/src/codegen/Tables.sol";
import { BlockDirection } from "@tenet-contracts/src/Types.sol";
import { getOppositeDirection } from "@tenet-contracts/src/Utils.sol";
import { registerExtension, entityIsPowerSignal, entityIsSignalSource, entityIsInvertedSignal, entityIsGenerator } from "../../Utils.sol";

contract PowerSignalSystem is SingleVoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    registerExtension(world, "PowerSignalSystem", IWorld(world).extension_PowerSignalSyste_eventHandler.selector);
  }

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view override returns (bool) {
    return entityIsPowerSignal(entityId, callerNamespace);
  }

  function runSingleInteraction(
    bytes16 callerNamespace,
    bytes32 powerSignalEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    PowerSignalData memory powerSignalData = PowerSignal.get(callerNamespace, powerSignalEntity);
    PowerWireData memory powerWireData = PowerWire.get(callerNamespace, powerSignalEntity);
    changedEntity = false;

    bool compareIsSignalSource = entityIsSignalSource(compareEntity, callerNamespace);
    bool compareIsActiveGenerator = entityIsGenerator(compareEntity, callerNamespace) &&
      Generator.get(callerNamespace, compareEntity).genRate > 0;
    bool compareIsActivePowerSignal = entityIsPowerSignal(compareEntity, callerNamespace);
    if (compareIsActivePowerSignal) {
      PowerSignalData memory comparePowerSignalData = PowerSignal.get(callerNamespace, compareEntity);
      compareIsActivePowerSignal =
        comparePowerSignalData.isActive &&
        comparePowerSignalData.direction != getOppositeDirection(compareBlockDirection);
    }
    bool compareIsActiveInvertedSignal = entityIsInvertedSignal(compareEntity, callerNamespace);
    if (compareIsActiveInvertedSignal) {
      InvertedSignalData memory compareInvertedSignalData = InvertedSignal.get(callerNamespace, compareEntity);
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
          PowerSignal.set(callerNamespace, powerSignalEntity, powerSignalData);
          changedEntity = true;
        }
      }

      if (powerWireData.isBroken) {
        powerSignalData.isActive = false;
        powerSignalData.direction = BlockDirection.None;
        PowerSignal.set(callerNamespace, powerSignalEntity, powerSignalData);
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
        PowerSignal.set(callerNamespace, powerSignalEntity, powerSignalData);
        changedEntity = true;
      }
    }

    return changedEntity;
  }

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public override returns (bytes32, bytes32[] memory) {
    return super.eventHandler(centerEntityId, neighbourEntityIds);
  }
}
