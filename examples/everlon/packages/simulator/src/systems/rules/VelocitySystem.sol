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
import { uint256ToInt32 } from "@tenet-utils/src/TypeUtils.sol";
import { isZeroCoord, voxelCoordsAreEqual } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { abs, absInt32 } from "@tenet-utils/src/MathUtils.sol";
import { NUM_BLOCKS_BEFORE_REDUCE_VELOCITY } from "@tenet-simulator/src/Constants.sol";

contract VelocitySystem is System {
  function updateVelocityCache(address worldAddress, bytes32 objectEntityId) public {
    if (!hasKey(VelocityTableId, Velocity.encodeKeyTuple(worldAddress, objectEntityId))) {
      return;
    }

    VoxelCoord memory velocity = getVelocity(worldAddress, objectEntityId);
    if (isZeroCoord(velocity)) {
      return;
    }
    // Calculate how many blocks have passed since last update
    uint256 blocksSinceLastUpdate = block.number - Velocity.getLastUpdateBlock(worldAddress, objectEntityId);
    if (blocksSinceLastUpdate == 0) {
      return;
    }
    // Calculate the new velocity

    int32 deltaV = uint256ToInt32(blocksSinceLastUpdate / NUM_BLOCKS_BEFORE_REDUCE_VELOCITY);
    // We dont want to reduce past 0
    VoxelCoord memory newVelocity = VoxelCoord({ x: 0, y: 0, z: 0 });

    // Update x component
    if (velocity.x > 0) {
      newVelocity.x = velocity.x > deltaV ? velocity.x - deltaV : int32(0);
    } else if (velocity.x < 0) {
      newVelocity.x = velocity.x < -deltaV ? velocity.x + deltaV : int32(0);
    }

    // Update y component
    if (velocity.y > 0) {
      newVelocity.y = velocity.y > deltaV ? velocity.y - deltaV : int32(0);
    } else if (velocity.y < 0) {
      newVelocity.y = velocity.y < -deltaV ? velocity.y + deltaV : int32(0);
    }

    // Update z component
    if (velocity.z > 0) {
      newVelocity.z = velocity.z > deltaV ? velocity.z - deltaV : int32(0);
    } else if (velocity.z < 0) {
      newVelocity.z = velocity.z < -deltaV ? velocity.z + deltaV : int32(0);
    }

    // Update the velocity
    if (!voxelCoordsAreEqual(velocity, newVelocity)) {
      Velocity.set(
        worldAddress,
        objectEntityId,
        VelocityData({ lastUpdateBlock: block.number, velocity: abi.encode(newVelocity) })
      );
    }
  }

  function velocityChange(
    address worldAddress,
    bytes32 actingObjectEntityId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bytes32 oldObjectEntityId,
    bytes32 objectEntityId
  ) public returns (bytes32) {
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
    {
      // Spend resources
      bool hasStamina = hasKey(StaminaTableId, Stamina.encodeKeyTuple(worldAddress, actingObjectEntityId));
      uint256 currentResourceAmount = hasStamina
        ? Stamina.get(worldAddress, actingObjectEntityId)
        : Temperature.get(worldAddress, actingObjectEntityId);
      require(resourceRequired <= currentResourceAmount, "VelocitySystem: Not enough resources to move.");
      if (hasStamina) {
        Stamina.set(worldAddress, actingObjectEntityId, currentResourceAmount - resourceRequired);
      } else {
        Temperature.set(worldAddress, actingObjectEntityId, currentResourceAmount - resourceRequired);
      }
    }

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
