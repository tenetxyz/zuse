// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy, EnergyTableId } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity, VelocityData, VelocityTableId } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Temperature, TemperatureTableId } from "@tenet-simulator/src/codegen/tables/Temperature.sol";

import { getVelocity } from "@tenet-simulator/src/Utils.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { abs, absInt32 } from "@tenet-utils/src/MathUtils.sol";

contract VelocitySystem is System {
  function velocityChange(
    address worldAddress,
    bytes32 actingObjectEntityId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bytes32 oldObjectEntityId,
    bytes32 objectEntityId
  ) public returns (bytes32 newEntityId) {
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, oldObjectEntityId)) &&
        hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, objectEntityId)),
      "VelocitySystem: Object entities not initialized"
    );
    require(
      Mass.get(worldAddress, oldObjectEntityId) == 0,
      "VelocitySystem: Cannot move on top of an entity with mass"
    );
    (VoxelCoord memory newVelocity, uint256 resourceRequired) = calculateNewVelocity(
      worldAddress,
      oldCoord,
      newCoord,
      objectEntityId,
      Mass.get(worldAddress, objectEntityId)
    );
    bool hasStamina = hasKey(StaminaTableId, Stamina.encodeKeyTuple(worldAddress, actingObjectEntityId));
    uint256 currentResourceAmount = hasStamina
      ? Stamina.get(worldAddress, actingObjectEntityId)
      : Temperature.get(worldAddress, actingObjectEntityId);
    require(resourceRequired <= currentResourceAmount, "VelocitySystem: Not enough resources to move.");

    // Flux energy
    IWorld(_world()).fluxEnergy(
      false,
      worldAddress,
      objectEntityId,
      resourceRequired + Energy.get(worldAddress, objectEntityId)
    );

    // Update velocity
    Velocity.set(
      worldAddress,
      objectEntityId,
      VelocityData({ lastUpdateBlock: block.number, velocity: abi.encode(newVelocity) })
    );

    // Spend resources
    if (hasStamina) {
      Stamina.set(worldAddress, actingObjectEntityId, currentResourceAmount - resourceRequired);
    } else {
      Temperature.set(worldAddress, actingObjectEntityId, currentResourceAmount - resourceRequired);
    }

    // Collision rule
    return IWorld(_world()).onCollision(worldAddress, objectEntityId, actingObjectEntityId);
  }

  function calculateNewVelocity(
    address worldAddress,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bytes32 objectEntityId,
    uint256 bodyMass
  ) internal view returns (VoxelCoord memory, uint256) {
    VoxelCoord memory currentVelocity = getVelocity(worldAddress, objectEntityId);
    VoxelCoord memory newVelocity = VoxelCoord({
      x: currentVelocity.x + (newCoord.x - oldCoord.x),
      y: currentVelocity.y + (newCoord.y - oldCoord.y),
      z: currentVelocity.z + (newCoord.z - oldCoord.z)
    });
    VoxelCoord memory velocityDelta = VoxelCoord({
      x: absInt32(newVelocity.x) - absInt32(currentVelocity.x),
      y: absInt32(newVelocity.y) - absInt32(currentVelocity.y),
      z: absInt32(newVelocity.z) - absInt32(currentVelocity.z)
    });

    uint256 resourceRequiredX = calculateResourceRequired(currentVelocity.x, velocityDelta.x, bodyMass);
    uint256 resourceRequiredY = calculateResourceRequired(currentVelocity.y, velocityDelta.y, bodyMass);
    uint256 resourceRequiredZ = calculateResourceRequired(currentVelocity.z, velocityDelta.z, bodyMass);
    uint256 resourceRequired = resourceRequiredX + resourceRequiredY + resourceRequiredZ;
    return (newVelocity, resourceRequired);
  }

  function calculateResourceRequired(
    int32 currentVelocity,
    int32 velocityDelta,
    uint256 bodyMass
  ) public pure returns (uint256) {
    uint256 resourceRequired = 0;
    int32 newVelocity = currentVelocity;

    // Determine loop direction based on sign of velocityDelta
    int32 increment = velocityDelta > 0 ? int32(1) : int32(-1);

    for (int i = 0; i != velocityDelta; i += increment) {
      currentVelocity = newVelocity;
      newVelocity += increment;

      uint256 amountRequired = bodyMass;
      if (newVelocity != 0) {
        bool sameDirection = (newVelocity > 0 && increment > 0) || (newVelocity < 0 && increment < 0);
        amountRequired = sameDirection
          ? bodyMass / uint(abs(int(newVelocity))) // if we're going in the same direction, then it costs less
          : bodyMass * uint(abs(int(newVelocity))); // if we're going in the opposite direction, then it costs more
      }
      resourceRequired += amountRequired;
    }

    return resourceRequired;
  }
}
