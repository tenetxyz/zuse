// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SingleVoxelInteraction } from "@tenet-contracts/src/prototypes/SingleVoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { PowerWire, PowerWireData, Generator, GeneratorData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { registerExtension, entityIsPowerWire, entityIsGenerator, entityIsPowerPlug, entityIsPowerPoint } from "../../Utils.sol";
import { getOppositeDirection } from "@tenet-contracts/src/Utils.sol";

contract PowerWireSystem is SingleVoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    registerExtension(world, "PowerWireSystem", IWorld(world).extension_PowerWireSystem_eventHandler.selector);
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

    bool isPowerWire = entityIsPowerWire(compareEntity, callerNamespace) &&
      PowerWire.get(callerNamespace, compareEntity).genRate > 0;
    bool isGenerator = entityIsGenerator(compareEntity, callerNamespace);

    bool doesHaveSource = powerWireData.source != bytes32(0);

    if (!doesHaveSource) {
      if (isPowerWire) {
        PowerWireData memory neighPowerWireData = PowerWire.get(callerNamespace, compareEntity);
        powerWireData.source = compareEntity;
        powerWireData.genRate = neighPowerWireData.genRate;
        powerWireData.direction = neighPowerWireData.direction;
        PowerWire.set(callerNamespace, signalEntity, powerWireData);
        changedEntity = true;
      } else if (isGenerator) {
        GeneratorData memory generatorData = Generator.get(callerNamespace, compareEntity);
        powerWireData.source = compareEntity;
        powerWireData.genRate = generatorData.genRate;
        powerWireData.direction = compareBlockDirection;
        PowerWire.set(callerNamespace, signalEntity, powerWireData);
        changedEntity = true;
      }
    } else {
      if (compareBlockDirection == powerWireData.direction) {
        if (entityIsGenerator(powerWireData.source, callerNamespace)) {
          GeneratorData memory generatorData = Generator.get(callerNamespace, compareEntity);
          if (powerWireData.genRate != generatorData.genRate) {
            powerWireData.genRate = generatorData.genRate;
            PowerWire.set(callerNamespace, signalEntity, powerWireData);
            changedEntity = true;
          }
        } else if (
          entityIsPowerWire(powerWireData.source, callerNamespace) &&
          PowerWire.get(callerNamespace, powerWireData.source).genRate > 0
        ) {
          PowerWireData memory neighPowerWireData = PowerWire.get(callerNamespace, compareEntity);
          if (powerWireData.genRate != neighPowerWireData.genRate) {
            powerWireData.genRate = neighPowerWireData.genRate;
            PowerWire.set(callerNamespace, signalEntity, powerWireData);
            changedEntity = true;
          }
        } else {
          powerWireData.source = bytes32(0);
          powerWireData.genRate = 0;
          powerWireData.direction = BlockDirection.None;
          PowerWire.set(callerNamespace, signalEntity, powerWireData);
          changedEntity = true;
        }
      } else {
        if (isGenerator) {
          revert("PowerWireSystem: PowerWire has a source and is trying to connect to a different source");
        } else if (isPowerWire) {
          PowerWireData memory neighPowerWireData = PowerWire.get(callerNamespace, compareEntity);
          if (neighPowerWireData.source != signalEntity) {
            // if we are not the source of this active wire
            revert("PowerWireSystem: PowerWire has a source and is trying to connect to a different source");
          }
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
