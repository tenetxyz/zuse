// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { Stamina, StaminaTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { isZeroCoord, voxelCoordsAreEqual, dot, mulScalar, divScalar, add, sub } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { abs, absInt32 } from "@tenet-utils/src/MathUtils.sol";
import { uint256ToInt32, int256ToUint256, safeSubtract } from "@tenet-utils/src/TypeUtils.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH } from "@tenet-utils/src/Constants.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { getVoxelTypeId, getVoxelCoordStrict, getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, getNeighbourEntities, createTerrainEntity, getEntityAtCoord } from "@tenet-simulator/src/Utils.sol";
import { NUM_BLOCKS_BEFORE_REDUCE_VELOCITY } from "@tenet-simulator/src/Constants.sol";
import { console } from "forge-std/console.sol";

contract VelocitySystem is SimHandler {
  function registerVelocitySelectors() public {
    SimSelectors.set(
      SimTable.Stamina,
      SimTable.Velocity,
      IWorld(_world()).updateVelocityFromStamina.selector,
      ValueType.Int256,
      ValueType.VoxelCoord
    );
  }

  function updateVelocityFromStamina(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderStaminaDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    VoxelCoord memory receiverVelocityDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    bool entityExists = hasKey(
      VelocityTableId,
      Velocity.encodeKeyTuple(callerAddress, receiverEntity.scale, receiverEntity.entityId)
    );
    // if (isEntityEqual(senderEntity, receiverEntity)) {} else {}
    // You can only spend stamina to decrease velocity
    // To increase, you have to move
    require(senderStaminaDelta > 0, "Stamina delta must be positive");
    require(
      receiverVelocityDelta.x <= 0 && receiverVelocityDelta.y <= 0 && receiverVelocityDelta.z <= 0,
      "Velocity delta must be negative"
    );
    VoxelCoord memory currentVelocity = getVelocity(callerAddress, receiverEntity);
    require(
      absInt32(currentVelocity.x) >= absInt32(receiverVelocityDelta.x) &&
        absInt32(currentVelocity.y) >= absInt32(receiverVelocityDelta.y) &&
        absInt32(currentVelocity.z) >= absInt32(receiverVelocityDelta.z),
      "Velocity delta must be less than current velocity"
    );
    VoxelCoord memory newVelocity = VoxelCoord({
      x: (currentVelocity.x >= 0)
        ? currentVelocity.x + receiverVelocityDelta.x
        : currentVelocity.x - receiverVelocityDelta.x,
      y: (currentVelocity.y >= 0)
        ? currentVelocity.y + receiverVelocityDelta.y
        : currentVelocity.y - receiverVelocityDelta.y,
      z: (currentVelocity.z >= 0)
        ? currentVelocity.z + receiverVelocityDelta.z
        : currentVelocity.z - receiverVelocityDelta.z
    });

    // Since this is always a decrease, the entity is always moving in the opposite direction
    // which means we do mass * new velocity
    uint256 resourceRequired = 0;
    {
      // Since the new velocity won't just be 1, we need to do a sum
      uint256 bodyMass = Mass.get(callerAddress, receiverEntity.scale, receiverEntity.entityId);
      uint256 resourceRequiredX = 0;
      int32 newVelocityX = currentVelocity.x;
      int32 currentVelocityX = currentVelocity.x;
      for (int x = receiverVelocityDelta.x; x < 0; x++) {
        currentVelocityX = newVelocityX;
        newVelocityX += newVelocityX.x > 0 ? -1 : 1;
        resourceRequiredX += calculateResourceRequired(currentVelocityX, newVelocityX, -1, bodyMass);
      }
      uint256 resourceRequiredY = 0;
      int32 newVelocityY = currentVelocity.y;
      int32 currentVelocityY = currentVelocity.y;
      for (int y = receiverVelocityDelta.y; y < 0; y++) {
        currentVelocityY = newVelocityY;
        newVelocityY += newVelocityY.y > 0 ? -1 : 1;
        resourceRequiredY += calculateResourceRequired(currentVelocityY, newVelocityY, -1, bodyMass);
      }
      uint256 resourceRequiredZ = 0;
      int32 newVelocityZ = currentVelocity.z;
      int32 currentVelocityZ = currentVelocity.z;
      for (int z = receiverVelocityDelta.z; z < 0; z++) {
        currentVelocityZ = newVelocityZ;
        newVelocityZ += newVelocityZ.z > 0 ? -1 : 1;
        resourceRequiredZ += calculateResourceRequired(currentVelocityZ, newVelocityZ, -1, bodyMass);
      }
      resourceRequired = resourceRequiredX + resourceRequiredY + resourceRequiredZ;
    }
    uint256 currentStamina = Stamina.get(callerAddress, senderEntity.scale, senderEntity.entityId);
    require(currentStamina >= resourceRequired, "Not enough stamina to spend");
    Stamina.set(callerAddress, senderEntity.scale, senderEntity.entityId, currentStamina - resourceRequired);
    IWorld(_world()).fluxEnergy(false, callerAddress, senderEntity, resourceRequired);
    Velocity.set(callerAddress, receiverEntity.scale, receiverEntity.entityId, block.number, abi.encode(newVelocity));
  }

  function reduceVelocity(VoxelEntity memory entity, VoxelCoord memory deltaVelocity) internal {}

  function updateVelocityCache(VoxelEntity memory entity) public {
    address callerAddress = super.getCallerAddress();
    if (!hasKey(VelocityTableId, Velocity.encodeKeyTuple(callerAddress, entity.scale, entity.entityId))) {
      return;
    }

    VoxelCoord memory velocity = getVelocity(callerAddress, entity);
    if (isZeroCoord(velocity)) {
      return;
    }
    // Calculate how many blocks have passed since last update
    uint256 blocksSinceLastUpdate = block.number -
      Velocity.getLastUpdateBlock(callerAddress, entity.scale, entity.entityId);
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
      Velocity.set(callerAddress, entity.scale, entity.entityId, block.number, abi.encode(newVelocity));
    }
  }

  function initTerrainEntity(
    address callerAddress,
    uint32 scale,
    VoxelCoord memory newCoord,
    VoxelEntity memory newEntity
  ) internal {
    uint256 terrainMass = getTerrainMass(callerAddress, scale, newCoord);
    require(terrainMass == 0, "Cannot move on top of terrain with mass");
    Mass.set(callerAddress, newEntity.scale, newEntity.entityId, terrainMass);
    Energy.set(
      callerAddress,
      newEntity.scale,
      newEntity.entityId,
      getTerrainEnergy(callerAddress, newEntity.scale, newCoord)
    );
    Velocity.set(
      callerAddress,
      newEntity.scale,
      newEntity.entityId,
      block.number,
      abi.encode(getTerrainVelocity(callerAddress, newEntity.scale, newCoord))
    );
  }

  function fluxEnergyForMove(address callerAddress, VoxelEntity memory newEntity, uint256 resourceRequired) internal {
    IWorld(_world()).fluxEnergy(
      false,
      callerAddress,
      newEntity,
      resourceRequired + Energy.get(callerAddress, newEntity.scale, newEntity.entityId)
    );
  }

  function velocityChange(
    VoxelEntity memory actingEntity,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    VoxelEntity memory oldEntity,
    VoxelEntity memory newEntity
  ) public returns (VoxelEntity memory) {
    address callerAddress = super.getCallerAddress();
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId)),
      "Old entity does not exist"
    );
    uint256 bodyMass = Mass.get(callerAddress, oldEntity.scale, oldEntity.entityId);
    (VoxelCoord memory newVelocity, uint256 resourceRequired) = calculateNewVelocity(
      callerAddress,
      oldCoord,
      newCoord,
      oldEntity,
      bodyMass
    );
    uint256 staminaInActingEntity = Stamina.get(callerAddress, actingEntity.scale, actingEntity.entityId);
    require(resourceRequired <= staminaInActingEntity, "Not enough stamina to move.");

    if (hasKey(MassTableId, Mass.encodeKeyTuple(callerAddress, newEntity.scale, newEntity.entityId))) {
      require(
        Mass.get(callerAddress, newEntity.scale, newEntity.entityId) == 0,
        "Cannot move on top of an entity with mass"
      );
    } else {
      initTerrainEntity(callerAddress, oldEntity.scale, newCoord, newEntity);
    }
    uint256 energyInOldBlock = Energy.get(callerAddress, oldEntity.scale, oldEntity.entityId);
    uint256 staminaInOldEntity = Stamina.get(callerAddress, oldEntity.scale, oldEntity.entityId);

    // Reset the old entity's mass, energy and velocity
    Mass.set(callerAddress, oldEntity.scale, oldEntity.entityId, 0);
    Energy.set(callerAddress, oldEntity.scale, oldEntity.entityId, 0);
    Velocity.set(
      callerAddress,
      oldEntity.scale,
      oldEntity.entityId,
      block.number,
      abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 }))
    );
    if (hasKey(StaminaTableId, Stamina.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
      Stamina.set(callerAddress, oldEntity.scale, oldEntity.entityId, 0);
    }

    fluxEnergyForMove(callerAddress, newEntity, resourceRequired);

    // Update the new entity's energy and velocity
    Mass.set(callerAddress, newEntity.scale, newEntity.entityId, bodyMass);
    Energy.set(callerAddress, newEntity.scale, newEntity.entityId, energyInOldBlock);
    Velocity.set(callerAddress, newEntity.scale, newEntity.entityId, block.number, abi.encode(newVelocity));
    // VoxelEntity memory newActingEntity = actingEntity;
    if (isEntityEqual(oldEntity, actingEntity)) {
      // newActingEntity = newEntity; // moving yourself, so update the acting entity
      Stamina.set(callerAddress, newEntity.scale, newEntity.entityId, staminaInActingEntity - resourceRequired);
    } else {
      if (hasKey(StaminaTableId, Stamina.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
        Stamina.set(callerAddress, newEntity.scale, newEntity.entityId, staminaInOldEntity);
      }
      Stamina.set(callerAddress, actingEntity.scale, actingEntity.entityId, staminaInActingEntity - resourceRequired);
    }

    return callOnCollision(callerAddress, actingEntity, oldEntity, newEntity);
  }

  function callOnCollision(
    address callerAddress,
    VoxelEntity memory actingEntity,
    VoxelEntity memory oldEntity,
    VoxelEntity memory newEntity
  ) internal returns (VoxelEntity memory) {
    return
      IWorld(_world()).onCollision(
        callerAddress,
        newEntity,
        isEntityEqual(oldEntity, actingEntity) ? newEntity : actingEntity
      );
  }

  function calculateNewVelocity(
    address callerAddress,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    VoxelEntity memory oldEntity,
    uint256 bodyMass
  ) internal view returns (VoxelCoord memory, uint256) {
    VoxelCoord memory currentVelocity = getVelocity(callerAddress, oldEntity);
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

    uint256 resourceRequiredX = calculateResourceRequired(currentVelocity.x, newVelocity.x, velocityDelta.x, bodyMass);
    uint256 resourceRequiredY = calculateResourceRequired(currentVelocity.y, newVelocity.y, velocityDelta.y, bodyMass);
    uint256 resourceRequiredZ = calculateResourceRequired(currentVelocity.z, newVelocity.z, velocityDelta.z, bodyMass);
    uint256 resourceRequired = resourceRequiredX + resourceRequiredY + resourceRequiredZ;
    return (newVelocity, resourceRequired);
  }

  // Note: We assume the magnitude of the delta is always 1,
  // ie the body is moving 1 voxel at a time
  function calculateResourceRequired(
    int32 currentVelocity,
    int32 newVelocity,
    int32 velocityDelta,
    uint256 bodyMass
  ) internal pure returns (uint256) {
    uint256 resourceRequired = 0;
    if (velocityDelta != 0) {
      resourceRequired = bodyMass;
      if (newVelocity != 0) {
        resourceRequired = velocityDelta > 0
          ? bodyMass / uint(abs(int(newVelocity))) // if we're going in the same direction, then it costs less
          : bodyMass * uint(abs(int(newVelocity))); // if we're going in the opposite direction, then it costs more
      }
    }
    return resourceRequired;
  }
}
