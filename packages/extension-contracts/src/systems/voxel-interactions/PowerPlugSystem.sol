// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SingleVoxelInteraction } from "@tenet-contracts/src/prototypes/SingleVoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { PowerPlug, PowerPlugData, PowerWire, PowerWireData, Generator, GeneratorData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { registerExtension, entityIsPowerWire, entityIsGenerator, entityIsPowerPlug } from "../../Utils.sol";
import { getOppositeDirection } from "@tenet-contracts/src/Utils.sol";

contract PowerPlugSystem is SingleVoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    registerExtension(world, "PowerPlugSystem", IWorld(world).extension_PowerPlugSystem_eventHandler.selector);
  }

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view override returns (bool) {
    return entityIsPowerPlug(entityId, callerNamespace);
  }

  function runSingleInteraction(
    bytes16 callerNamespace,
    bytes32 signalEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    PowerPlugData memory powerPlugData = PowerPlug.get(callerNamespace, signalEntity);
    changedEntity = false;

    if (entityIsGenerator(compareEntity, callerNamespace)) {
      GeneratorData memory compareGeneratorData = Generator.get(callerNamespace, compareEntity);
      if (powerPlugData.source != compareEntity  || powerPlugData.direction != compareBlockDirection
          || powerPlugData.genRate != (compareGeneratorData.genRate * 14) / 15)
      {
        powerPlugData.source = compareEntity;
        powerPlugData.genRate = (compareGeneratorData.genRate * 14) / 15;
        powerPlugData.direction = compareBlockDirection;
        PowerPlug.set(callerNamespace, signalEntity, powerPlugData);
        changedEntity = true;
      }
    } 

    else if (entityIsPowerWire(compareEntity, callerNamespace)) {
      PowerWireData memory compareWireData = PowerWire.get(callerNamespace, compareEntity);
      if (powerPlugData.destination != compareWireData.destination ||
          compareWireData.direction != getOppositeDirection(compareBlockDirection)) {
        powerPlugData.destination = compareWireData.destination;
        PowerPlug.set(callerNamespace, signalEntity, powerPlugData);
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
