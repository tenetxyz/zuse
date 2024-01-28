// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { ExternalObjectSystem as ExternalObjectProtoSystem } from "@tenet-base-world/src/systems/ExternalObjectSystem.sol";

import { SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Health, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";

contract ExternalObjectSystem is ExternalObjectProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function getObjectProperties(bytes32 objectEntityId) public view override returns (ObjectProperties memory) {
    IStore store = IStore(getSimulatorAddress());
    address worldAddress = _world();
    ObjectProperties memory objectProperties;

    objectProperties.mass = Mass.get(store, worldAddress, objectEntityId);
    objectProperties.energy = Energy.get(store, worldAddress, objectEntityId);
    objectProperties.velocity = Velocity.getVelocity(store, worldAddress, objectEntityId);
    objectProperties.lastUpdateBlock = Velocity.getLastUpdateBlock(store, worldAddress, objectEntityId);
    objectProperties.health = Health.getHealth(store, worldAddress, objectEntityId);
    objectProperties.hasHealth = hasKey(store, HealthTableId, Health.encodeKeyTuple(worldAddress, objectEntityId));
    objectProperties.stamina = Stamina.get(store, worldAddress, objectEntityId);
    objectProperties.hasStamina = hasKey(store, StaminaTableId, Stamina.encodeKeyTuple(worldAddress, objectEntityId));

    return objectProperties;
  }
}
