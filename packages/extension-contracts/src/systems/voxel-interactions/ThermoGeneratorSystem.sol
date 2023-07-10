// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelInteraction } from "../../prototypes/VoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Generator, TemperatureAtTime, GeneratorData, Temperature, TemperatureData, TemperatureAtTimeData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { registerExtension, entityIsGenerator, entityHasTemperature } from "../../Utils.sol";

contract ThermoGeneratorSystem is VoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    registerExtension(world, "ThermoGeneratorSystem", IWorld(world).extension_ThermoGeneratorS_eventHandler.selector);
  }

  function onNewNeighbour(
    bytes16 callerNamespace,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal override returns (bool changedEntity) {
      GeneratorData memory generatorData = Generator.get(callerNamespace, interactEntity);
      
      if (generatorData.sources.length == 2) {
          // Call entityHasTemperature(source[i], callerNamespace) on both and return true if one is false
          return !(entityHasTemperature(generatorData.sources[0], callerNamespace) && entityHasTemperature(generatorData.sources[1], callerNamespace));
      }      
      else if (entityHasTemperature(neighbourEntityId, callerNamespace)) {
          return true;
      }
      else {
          return false;
      }
  }

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view override returns (bool) {
    return entityIsGenerator(entityId, callerNamespace);
  }

  struct TemperatureEntity {
    bytes32 entity;
    TemperatureData data;
  }

  function runInteraction(
    bytes16 callerNamespace,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections
  ) internal override returns (bool changedEntity) {

    GeneratorData memory generatorData = Generator.get(callerNamespace, interactEntity);
    changedEntity = false;
    
    TemperatureEntity[] memory tempDataEntities = new TemperatureEntity[](2);
    uint256 count = 0;

    for (uint256 i = 0; i < neighbourEntityIds.length && count < 2; i++) {
        if (entityHasTemperature(neighbourEntityIds[i], callerNamespace)) {
            // Create a new TemperatureEntity
            TemperatureEntity memory tempEntity;
            tempEntity.entity = neighbourEntityIds[i];
            tempEntity.data = Temperature.get(callerNamespace, neighbourEntityIds[i]);

            // Add it to the memory array
            tempDataEntities[count] = tempEntity;
            count++;
        }
    }

    if (count == 2) {
     changedEntity = handleTempDataEntities(callerNamespace, interactEntity, generatorData, tempDataEntities);
    } else {
      if (generatorData.genRate != 0 && generatorData.sources.length != 0) {
            generatorData.genRate = 0;
            generatorData.sources = new bytes32[](0);
            Generator.set(callerNamespace, interactEntity, generatorData);
      }
    }

    return changedEntity;
  }

  function handleTempDataEntities(
    bytes16 callerNamespace,
    bytes32 interactEntity,
    GeneratorData memory generatorData,
    TemperatureEntity[] memory tempDataEntities
  ) internal returns (bool changedEntity) {

    if (block.number != tempDataEntities[0].data.lastUpdateBlock || block.number != tempDataEntities[1].data.lastUpdateBlock) {
      TemperatureAtTimeData memory Temp1AtTime;
      Temp1AtTime.temperature = tempDataEntities[0].data.temperature;
      Temp1AtTime.lastUpdateBlock = tempDataEntities[0].data.lastUpdateBlock;

      TemperatureAtTimeData memory Temp2AtTime;
      Temp2AtTime.temperature = tempDataEntities[1].data.temperature;
      Temp2AtTime.lastUpdateBlock = tempDataEntities[1].data.lastUpdateBlock;

      TemperatureAtTime.set(callerNamespace, tempDataEntities[0].entity, Temp1AtTime);
      TemperatureAtTime.set(callerNamespace, tempDataEntities[1].entity, Temp2AtTime);

      changedEntity = false;
    } else {
      
      TemperatureAtTimeData memory Temp1AtTimeData = TemperatureAtTime.get(callerNamespace, tempDataEntities[0].entity);
      TemperatureAtTimeData memory Temp2AtTimeData = TemperatureAtTime.get(callerNamespace, tempDataEntities[1].entity);

      uint256 absoluteDifferenceAtTime;
      if(Temp1AtTimeData.temperature >= Temp2AtTimeData.temperature) {
          absoluteDifferenceAtTime = Temp1AtTimeData.temperature - Temp2AtTimeData.temperature;
      } else {
          absoluteDifferenceAtTime = Temp2AtTimeData.temperature - Temp1AtTimeData.temperature;
      }

      TemperatureData memory temp1Data = Temperature.get(callerNamespace, tempDataEntities[0].entity);
      TemperatureData memory temp2Data = Temperature.get(callerNamespace, tempDataEntities[1].entity);

      uint256 absoluteDifferenceNow;
      if(temp1Data.temperature >= temp2Data.temperature) {
          absoluteDifferenceNow = temp1Data.temperature - temp2Data.temperature;
      } else {
          absoluteDifferenceNow = temp2Data.temperature - temp1Data.temperature;
      }

      bytes32[] memory sources = new bytes32[](2);
      sources[0] = tempDataEntities[0].entity;
      sources[1] = tempDataEntities[1].entity;

      uint256 newGenRate = (absoluteDifferenceAtTime + absoluteDifferenceNow) / 2;

      if (generatorData.genRate != newGenRate) {
        generatorData.genRate = newGenRate;
        generatorData.sources = sources;
        Generator.set(callerNamespace, interactEntity, generatorData);
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
