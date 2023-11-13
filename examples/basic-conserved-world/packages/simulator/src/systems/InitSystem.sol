// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Health, HealthTableId, Stamina, StaminaTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { console } from "forge-std/console.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";

contract InitSystem is System {
  function initEntity(
    VoxelEntity memory entity,
    uint256 initMass,
    uint256 initEnergy,
    VoxelCoord memory initVelocity
  ) public {
    address callerAddress = _msgSender();
    require(
      !Mass.getHasValue(callerAddress, entity.scale, entity.entityId) &&
        !hasKey(EnergyTableId, Energy.encodeKeyTuple(callerAddress, entity.scale, entity.entityId)) &&
        !hasKey(VelocityTableId, Velocity.encodeKeyTuple(callerAddress, entity.scale, entity.entityId)),
      "Entity already initialized"
    );
    Mass.set(callerAddress, entity.scale, entity.entityId, initMass, true);
    Energy.set(callerAddress, entity.scale, entity.entityId, initEnergy);
    Velocity.set(callerAddress, entity.scale, entity.entityId, block.number, abi.encode(initVelocity));
  }

  function initAgent(VoxelEntity memory entity, uint256 initStamina, uint256 initHealth) public {
    address callerAddress = _msgSender();
    require(
      !hasKey(StaminaTableId, Stamina.encodeKeyTuple(callerAddress, entity.scale, entity.entityId)) &&
        !hasKey(HealthTableId, Health.encodeKeyTuple(callerAddress, entity.scale, entity.entityId)),
      "Agent entity already initialized"
    );
    Stamina.set(callerAddress, entity.scale, entity.entityId, initStamina);
    Health.set(callerAddress, entity.scale, entity.entityId, 0, initHealth);
  }
}
