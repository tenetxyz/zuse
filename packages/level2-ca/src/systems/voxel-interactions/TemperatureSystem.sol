// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SingleVoxelInteraction } from "@tenet-base-ca/src/prototypes/SingleVoxelInteraction.sol";
import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { Temperature, TemperatureData } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { BlockDirection } from "@tenet-utils/src/Types.sol";
import { entityIsSignal, entityHasTemperature } from "@tenet-level2-ca/src/InteractionUtils.sol";

contract TemperatureSystem is SingleVoxelInteraction {
  function runSingleInteraction(
    address callerAddress,
    bytes32 temperatureEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    TemperatureData memory temperatureData = Temperature.get(callerAddress, temperatureEntity);
    changedEntity = false;

    uint256 roomTemperature = 20000;
    uint256 currentTemperature = temperatureData.temperature;
    uint256 lastUpdateBlock = temperatureData.lastUpdateBlock;

    uint256 blocksPassed = block.number - lastUpdateBlock;

    if (currentTemperature > roomTemperature) {
      currentTemperature -= blocksPassed;
      if (currentTemperature < roomTemperature) {
        currentTemperature = roomTemperature;
      }
    } else if (currentTemperature < roomTemperature) {
      currentTemperature += blocksPassed;
      if (currentTemperature > roomTemperature) {
        currentTemperature = roomTemperature;
      }
    }
    lastUpdateBlock = block.number;

    if (temperatureData.lastUpdateBlock != lastUpdateBlock) {
      temperatureData.temperature = currentTemperature;
      temperatureData.lastUpdateBlock = lastUpdateBlock;
      Temperature.set(callerAddress, temperatureEntity, temperatureData);
      changedEntity = true;
    }

    return changedEntity;
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    return entityHasTemperature(callerAddress, entityId);
  }

  function eventHandlerTemperature(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
