// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelInteraction } from "@tenet-contracts/src/prototypes/VoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { PowerPlug, PowerPlugData, PowerWire, PowerWireData, Generator, GeneratorData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { registerExtension, entityIsPowerWire, entityIsGenerator, entityIsPowerPlug } from "../../Utils.sol";
import { getOppositeDirection } from "@tenet-contracts/src/Utils.sol";

contract PowerPlugSystem is VoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    registerExtension(world, "PowerPlugSystem", IWorld(world).extension_PowerPlugSystem_eventHandler.selector);
  }

  function onNewNeighbour(
    bytes16 callerNamespace,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal override returns (bool changedEntity) {
    // if (entityIsGenerator(neighbourEntityId, callerNamespace)){
    //   return true;
    // }
    // else if (entityIsPowerWire(neighbourEntityId, callerNamespace)){
    //   return true;
    // }
    // else {
    //   return false;
    // }
    return true;
  }

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view override returns (bool) {
    return entityIsPowerPlug(entityId, callerNamespace);
  }

  function runInteraction(
    bytes16 callerNamespace,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections
  ) internal override returns (bool changedEntity) {
    PowerPlugData memory powerPlugData = PowerPlug.get(callerNamespace, interactEntity);
    changedEntity = false;

    for (uint256 i = 0; i < neighbourEntityIds.length; i++) {
        if (entityIsGenerator(neighbourEntityIds[i], callerNamespace)) {
            GeneratorData memory compareGeneratorData = Generator.get(callerNamespace, neighbourEntityIds[i]);

            if (powerPlugData.source != neighbourEntityIds[i]  || powerPlugData.direction != neighbourEntityDirections[i]
                || powerPlugData.genRate != (compareGeneratorData.genRate * 14) / 15) 
            {
                powerPlugData.source = neighbourEntityIds[i];
                powerPlugData.genRate = (compareGeneratorData.genRate * 14) / 15;
                powerPlugData.direction = neighbourEntityDirections[i];
                PowerPlug.set(callerNamespace, interactEntity, powerPlugData);
                changedEntity = true;
            }

            break;
        }
    }








        //  else {
        //   if (powerPlugData.source != bytes32(0)  || powerPlugData.direction != BlockDirection.None
        //       || powerPlugData.genRate != 0)
        //   {
        //     powerPlugData.source = bytes32(0);
        //     powerPlugData.genRate = 0;
        //     powerPlugData.direction = BlockDirection.None;
        //     PowerPlug.set(callerNamespace, interactEntity, powerPlugData);
        //     changedEntity = true;
        //   }
        // }

    // if (entityIsGenerator(compareEntity, callerNamespace)) {
    //   GeneratorData memory compareGeneratorData = Generator.get(callerNamespace, compareEntity);
    //   if (powerPlugData.source != compareEntity  || powerPlugData.direction != compareBlockDirection
    //       || powerPlugData.genRate != (compareGeneratorData.genRate * 14) / 15)
    //   {
    //     powerPlugData.source = compareEntity;
    //     powerPlugData.genRate = (compareGeneratorData.genRate * 14) / 15;
    //     powerPlugData.direction = compareBlockDirection;
    //     PowerPlug.set(callerNamespace, signalEntity, powerPlugData);
    //     changedEntity = true;
    //   }
    // } 
    
    
    // if (powerPlugData.source != compareEntity) {
    //   if (powerPlugData.source != bytes32(0)  || powerPlugData.direction != BlockDirection.None
    //       || powerPlugData.genRate != 0)
    //   {
    //     powerPlugData.source = bytes32(0);
    //     powerPlugData.genRate = 0;
    //     powerPlugData.direction = BlockDirection.None;
    //     PowerPlug.set(callerNamespace, signalEntity, powerPlugData);
    //     changedEntity = true;
    //   }
    // }

    // if (entityIsPowerWire(compareEntity, callerNamespace)) {
    //   PowerWireData memory compareWireData = PowerWire.get(callerNamespace, compareEntity);
    //   if (powerPlugData.destination != compareWireData.destination ||
    //       compareWireData.direction != getOppositeDirection(compareBlockDirection)) {
    //     powerPlugData.destination = compareWireData.destination;
    //     PowerPlug.set(callerNamespace, signalEntity, powerPlugData);
    //     changedEntity = true;
    //   }
    // }

    return changedEntity;
  }

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public override returns (bytes32, bytes32[] memory) {
    return super.eventHandler(centerEntityId, neighbourEntityIds);
  }
}