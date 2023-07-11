// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SingleVoxelInteraction } from "../../prototypes/SingleVoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { PowerPlug, PowerPlugData, PowerWire, PowerWireData, Generator, GeneratorData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { registerExtension, getOppositeDirection, entityIsPowerWire, entityIsGenerator, entityIsPowerPlug } from "../../Utils.sol";

contract PowerPlugSystem is SingleVoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    registerExtension(world, "PowerWireSystem", IWorld(world).extension_PowerPlugSystem_eventHandler.selector);
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

    bool compareIsGenSource = entityIsGenerator(compareEntity, callerNamespace);
    bool compareIsWireSource = entityIsPowerWire(compareEntity, callerNamespace);

    if (compareIsGenSource) {
      GeneratorData memory compareGeneratorData = Generator.get(callerNamespace, compareEntity);
      compareIsGenSource = compareGeneratorData.genRate > 0;
    } else if (compareIsWireSource) {
      PowerWireData memory compareWireData = PowerWire.get(callerNamespace, compareEntity);
      compareIsWireSource = compareWireData.genRate > 0 && compareWireData.direction != getOppositeDirection(compareBlockDirection);
    }

    if (compareIsGenSource) {
      GeneratorData memory compareGeneratorData = Generator.get(callerNamespace, compareEntity);
      powerPlugData.source = compareEntity;
      powerPlugData.genRate = compareGeneratorData.genRate;
      powerPlugData.direction = compareBlockDirection;
      PowerPlug.set(callerNamespace, signalEntity, powerPlugData);
      changedEntity = true;
    } else if (compareIsWireSource) {
      PowerWireData memory compareWireData = PowerWire.get(callerNamespace, compareEntity);
      powerPlugData.destination = compareWireData.destination;
      changedEntity = true;
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
