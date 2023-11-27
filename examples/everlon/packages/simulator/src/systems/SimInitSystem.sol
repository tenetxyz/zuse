// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimInitSystem as SimInitProtoSystem } from "@tenet-base-simulator/src/systems/SimInitSystem.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy, EnergyTableId } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Health, HealthData, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { ObjectProperties } from "@tenet-utils/src/Types.sol";

contract SimInitSystem is SimInitProtoSystem {
  function initObject(bytes32 objectEntityId, ObjectProperties memory initialProperties) public override {
    address world = _msgSender();
    require(
      !hasKey(MassTableId, Mass.encodeKeyTuple(world, objectEntityId)),
      "SimInitSystem: Mass for object already initialized"
    );
    require(
      !hasKey(EnergyTableId, Energy.encodeKeyTuple(world, objectEntityId)),
      "SimInitSystem: Energy for object already initialized"
    );
    Mass.set(world, objectEntityId, initialProperties.mass);
    Energy.set(world, objectEntityId, initialProperties.energy);
    if (initialProperties.health > 0) {
      require(
        !hasKey(HealthTableId, Health.encodeKeyTuple(world, objectEntityId)),
        "SimInitSystem: Health for object already initialized"
      );
      Health.set(
        world,
        objectEntityId,
        HealthData({ lastUpdateBlock: block.number, health: initialProperties.health })
      );
    }
    if (initialProperties.stamina > 0) {
      require(
        !hasKey(StaminaTableId, Stamina.encodeKeyTuple(world, objectEntityId)),
        "SimInitSystem: Stamina for object already initialized"
      );
      Stamina.set(world, objectEntityId, initialProperties.stamina);
    }
  }
}
