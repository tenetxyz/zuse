// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelInteraction } from "@tenet-base-ca/src/prototypes/VoxelInteraction.sol";
import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { Generator, TemperatureAtTime, GeneratorData, Temperature, TemperatureData, TemperatureAtTimeData } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { BlockDirection } from "@tenet-utils/src/Types.sol";
import { entityIsGenerator, entityHasTemperature } from "@tenet-level2-ca/src/InteractionUtils.sol";

struct TemperatureEntity {
  bytes32 entity;
  BlockDirection entityBlockDirection;
  TemperatureData data;
}

contract ThermoGeneratorSystem is VoxelInteraction {
  function onNewNeighbour(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal override returns (bool changedEntity) {
    GeneratorData memory generatorData = Generator.get(callerAddress, interactEntity);
    bool isSourceDirection = false;
    if (generatorData.sources.length == 2) {
      BlockDirection[] memory sourceDirections = abi.decode(generatorData.sourceDirections, (BlockDirection[]));
      isSourceDirection =
        sourceDirections[0] == neighbourBlockDirection ||
        sourceDirections[1] == neighbourBlockDirection;
    }

    return
      entityHasTemperature(callerAddress, neighbourEntityId) ||
      //   entityIsPowerWire(callerAddress, neighbourEntityId) ||
      isSourceDirection;
  }

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bool changedEntity) {
    GeneratorData memory generatorData = Generator.get(callerAddress, interactEntity);
    changedEntity = false;

    TemperatureEntity[] memory tempDataEntities = new TemperatureEntity[](2);
    uint256 count = 0;
    bytes32 source1 = bytes32(0);
    bytes32 source2 = bytes32(0);
    if (
      generatorData.sources.length == 2 &&
      entityHasTemperature(callerAddress, generatorData.sources[0]) &&
      entityHasTemperature(callerAddress, generatorData.sources[1])
    ) {
      // already have sources
      TemperatureEntity memory source1Entity;
      source1Entity.entity = generatorData.sources[0];
      source1Entity.data = Temperature.get(callerAddress, generatorData.sources[0]);
      BlockDirection[] memory sourceDirections = abi.decode(generatorData.sourceDirections, (BlockDirection[]));
      source1Entity.entityBlockDirection = sourceDirections[0];
      tempDataEntities[0] = source1Entity;

      TemperatureEntity memory source2Entity;
      source2Entity.entity = generatorData.sources[1];
      source2Entity.entityBlockDirection = sourceDirections[1];
      source2Entity.data = Temperature.get(callerAddress, generatorData.sources[1]);
      tempDataEntities[1] = source2Entity;
      count = 2;
    } else {
      for (uint256 i = 0; i < neighbourEntityIds.length && count < 2; i++) {
        if (entityHasTemperature(callerAddress, neighbourEntityIds[i])) {
          // Create a new TemperatureEntity
          TemperatureEntity memory tempEntity;
          tempEntity.entity = neighbourEntityIds[i];
          tempEntity.data = Temperature.get(callerAddress, neighbourEntityIds[i]);
          tempEntity.entityBlockDirection = neighbourEntityDirections[i];

          // Add it to the memory array
          tempDataEntities[count] = tempEntity;
          count++;
        }
      }
    }

    if (count == 2) {
      changedEntity = handleTempDataEntities(callerAddress, interactEntity, generatorData, tempDataEntities);
    } else {
      if (generatorData.sources.length != 0) {
        generatorData.genRate = 0;
        generatorData.sources = new bytes32[](0);
        generatorData.sourceDirections = abi.encode(new BlockDirection[](0));
        Generator.set(callerAddress, interactEntity, generatorData);
      }
    }

    return changedEntity;
  }

  function handleTempDataEntities(
    address callerAddress,
    bytes32 interactEntity,
    GeneratorData memory generatorData,
    TemperatureEntity[] memory tempDataEntities
  ) internal returns (bool changedEntity) {
    if (
      block.number != tempDataEntities[0].data.lastUpdateBlock ||
      block.number != tempDataEntities[1].data.lastUpdateBlock
    ) {
      TemperatureAtTimeData memory Temp1AtTime;
      Temp1AtTime.temperature = tempDataEntities[0].data.temperature;
      Temp1AtTime.lastUpdateBlock = tempDataEntities[0].data.lastUpdateBlock;

      TemperatureAtTimeData memory Temp2AtTime;
      Temp2AtTime.temperature = tempDataEntities[1].data.temperature;
      Temp2AtTime.lastUpdateBlock = tempDataEntities[1].data.lastUpdateBlock;

      TemperatureAtTime.set(callerAddress, tempDataEntities[0].entity, Temp1AtTime);
      TemperatureAtTime.set(callerAddress, tempDataEntities[1].entity, Temp2AtTime);

      changedEntity = false;
    } else {
      TemperatureAtTimeData memory Temp1AtTimeData = TemperatureAtTime.get(callerAddress, tempDataEntities[0].entity);
      TemperatureAtTimeData memory Temp2AtTimeData = TemperatureAtTime.get(callerAddress, tempDataEntities[1].entity);

      uint256 absoluteDifferenceAtTime;
      if (Temp1AtTimeData.temperature >= Temp2AtTimeData.temperature) {
        absoluteDifferenceAtTime = Temp1AtTimeData.temperature - Temp2AtTimeData.temperature;
      } else {
        absoluteDifferenceAtTime = Temp2AtTimeData.temperature - Temp1AtTimeData.temperature;
      }

      TemperatureData memory temp1Data = Temperature.get(callerAddress, tempDataEntities[0].entity);
      TemperatureData memory temp2Data = Temperature.get(callerAddress, tempDataEntities[1].entity);

      uint256 absoluteDifferenceNow;
      if (temp1Data.temperature >= temp2Data.temperature) {
        absoluteDifferenceNow = temp1Data.temperature - temp2Data.temperature;
      } else {
        absoluteDifferenceNow = temp2Data.temperature - temp1Data.temperature;
      }

      bytes32[] memory sources = new bytes32[](2);
      sources[0] = tempDataEntities[0].entity;
      sources[1] = tempDataEntities[1].entity;

      BlockDirection[] memory sourceDirections = new BlockDirection[](2);
      sourceDirections[0] = tempDataEntities[0].entityBlockDirection;
      sourceDirections[1] = tempDataEntities[1].entityBlockDirection;

      uint256 newGenRate = (absoluteDifferenceAtTime + absoluteDifferenceNow) / 2;

      if (generatorData.genRate != newGenRate) {
        generatorData.genRate = newGenRate;
        generatorData.sources = sources;
        generatorData.sourceDirections = abi.encode(sourceDirections);
        Generator.set(callerAddress, interactEntity, generatorData);
        changedEntity = true;
      }
    }

    return changedEntity;
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    return entityIsGenerator(callerAddress, entityId);
  }

  function eventHandlerThermoGenerator(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
