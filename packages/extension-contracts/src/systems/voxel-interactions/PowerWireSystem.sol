// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SingleVoxelInteraction } from "@tenet-contracts/src/prototypes/SingleVoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { PowerPlug, PowerPlugData, PowerWire, PowerWireData, Generator, GeneratorData, PowerPoint, PowerPointData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { registerExtension, entityIsPowerWire, entityIsGenerator, entityIsPowerPlug, entityIsPowerPoint } from "../../Utils.sol";
import { getOppositeDirection } from "@tenet-contracts/src/Utils.sol";

contract PowerWireSystem is SingleVoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    registerExtension(world, "PowerPlugSystem", IWorld(world).extension_PowerPlugSystem_eventHandler.selector);
  }

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view override returns (bool) {
    return entityIsPowerWire(entityId, callerNamespace);
  }

  function runSingleInteraction(
    bytes16 callerNamespace,
    bytes32 signalEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    PowerWireData memory powerWireData = PowerWire.get(callerNamespace, signalEntity);
    changedEntity = false;

    if (entityIsPowerPlug(compareEntity, callerNamespace)) {
      PowerPlugData memory powerPlugData = PowerPlug.get(callerNamespace, compareEntity);
      if (powerWireData.source != powerPlugData.source  || powerWireData.direction != compareBlockDirection
          || powerWireData.genRate != (powerPlugData.genRate * 14) / 15) {
        powerWireData.source = powerPlugData.source;
        powerWireData.direction = compareBlockDirection;
        powerWireData.genRate = (powerPlugData.genRate * 14) / 15;
        PowerWire.set(callerNamespace, signalEntity, powerWireData);
        changedEntity = true;
      }
    }

    if (entityIsPowerPoint(compareEntity, callerNamespace)) {
      PowerPointData memory powerPointData = PowerPoint.get(callerNamespace, compareEntity);
      if (powerWireData.destination != powerPointData.destination) {
        powerWireData.destination = powerPointData.destination;
        PowerWire.set(callerNamespace, signalEntity, powerWireData);
        changedEntity = true;
      }
    }

    if (entityIsPowerWire(compareEntity, callerNamespace)) {
      PowerWireData memory comparePowerWireData = PowerWire.get(callerNamespace, compareEntity);
      if (comparePowerWireData.destination != bytes32(0)) {
        if (powerWireData.destination != comparePowerWireData.destination) {
          powerWireData.destination = comparePowerWireData.destination;
          PowerWire.set(callerNamespace, signalEntity, powerWireData);
          changedEntity = true;
        }
      }
      if (comparePowerWireData.source != bytes32(0)) {
        if (powerWireData.source != comparePowerWireData.source  || powerWireData.direction != compareBlockDirection
            || powerWireData.genRate != (comparePowerWireData.genRate * 14) / 15) {
          powerWireData.source = comparePowerWireData.source;
          powerWireData.direction = compareBlockDirection;
          powerWireData.genRate = (comparePowerWireData.genRate * 14) / 15;
          PowerWire.set(callerNamespace, signalEntity, powerWireData);
          changedEntity = true;
        }
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