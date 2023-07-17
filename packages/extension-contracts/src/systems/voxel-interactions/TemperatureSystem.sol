// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SingleVoxelInteraction } from "@tenet-contracts/src/prototypes/SingleVoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Temperature, TemperatureData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { registerExtension, entityHasTemperature } from "../../Utils.sol";

contract TemperatureSystem is SingleVoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    registerExtension(world, "TemperatureSystem", IWorld(world).extension_TemperatureSyste_eventHandler.selector);
  }

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view override returns (bool) {
    return entityHasTemperature(entityId, callerNamespace);
  }

  function runSingleInteraction(
    bytes16 callerNamespace,
    bytes32 temperatureEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    TemperatureData memory temperatureData = Temperature.get(callerNamespace, temperatureEntity);
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
      Temperature.set(callerNamespace, temperatureEntity, temperatureData);
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
