// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimInitSystem as SimInitProtoSystem } from "@tenet-base-simulator/src/systems/SimInitSystem.sol";

import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy, EnergyTableId } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity, VelocityData, VelocityTableId } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Health, HealthData, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";

import { VoxelCoord, ObjectProperties, ElementType } from "@tenet-utils/src/Types.sol";

contract SimInitSystem is SimInitProtoSystem {
  function initObject(bytes32 objectEntityId, ObjectProperties memory initialProperties) public override {
    address worldAddress = _msgSender();
    require(
      !hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, objectEntityId)),
      "SimInitSystem: Mass for object already initialized"
    );
    require(
      !hasKey(EnergyTableId, Energy.encodeKeyTuple(worldAddress, objectEntityId)),
      "SimInitSystem: Energy for object already initialized"
    );
    require(
      !hasKey(EnergyTableId, Energy.encodeKeyTuple(worldAddress, objectEntityId)),
      "SimInitSystem: Energy for object already initialized"
    );
    Mass.set(worldAddress, objectEntityId, initialProperties.mass);
    Energy.set(worldAddress, objectEntityId, initialProperties.energy);
    bytes memory velocity = initialProperties.velocity;
    if (velocity.length == 0) {
      velocity = abi.encode(VoxelCoord(0, 0, 0));
    }
    Velocity.set(worldAddress, objectEntityId, VelocityData({ lastUpdateBlock: block.number, velocity: velocity }));
    if (initialProperties.health > 0) {
      require(
        !hasKey(HealthTableId, Health.encodeKeyTuple(worldAddress, objectEntityId)),
        "SimInitSystem: Health for object already initialized"
      );
      Health.set(
        worldAddress,
        objectEntityId,
        HealthData({ lastUpdateBlock: block.number, health: initialProperties.health })
      );
    }
    if (initialProperties.stamina > 0) {
      require(
        !hasKey(StaminaTableId, Stamina.encodeKeyTuple(worldAddress, objectEntityId)),
        "SimInitSystem: Stamina for object already initialized"
      );
      Stamina.set(worldAddress, objectEntityId, initialProperties.stamina);
    }
  }
}
