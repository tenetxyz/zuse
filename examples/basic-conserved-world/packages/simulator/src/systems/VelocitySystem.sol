// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimHandler } from "@tenet-simulator/prototypes/SimHandler.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ValueType, SimTable } from "@tenet-utils/src/Types.sol";
import { SimSelectors, Temperature, TemperatureTableId, Stamina, StaminaTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
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

enum MovementResource {
  Stamina,
  Temperature
}

struct EntityData {
  uint256 mass;
  uint256 energy;
  uint256 resource;
}

contract VelocitySystem is SimHandler {
  function registerVelocitySelectors() public {
    SimSelectors.set(
      SimTable.Stamina,
      SimTable.Velocity,
      IWorld(_world()).updateVelocityFromStamina.selector,
      ValueType.Int256,
      ValueType.VoxelCoord
    );

    SimSelectors.set(
      SimTable.Stamina,
      SimTable.Velocity,
      IWorld(_world()).updateVelocityFromTemperature.selector,
      ValueType.Int256,
      ValueType.VoxelCoordArray
    );
  }

  function updateVelocityFromTemperature(
    VoxelEntity memory senderEntity,
    VoxelCoord memory senderCoord,
    int256 senderTemperatureDelta,
    VoxelEntity memory receiverEntity,
    VoxelCoord memory receiverCoord,
    VoxelCoord[] memory receiverPositionDelta
  ) public {
    address callerAddress = super.getCallerAddress();
    {
      bool entityExists = hasKey(
        TemperatureTableId,
        Temperature.encodeKeyTuple(callerAddress, senderEntity.scale, senderEntity.entityId)
      );
      require(entityExists, "Sender entity does not exist");
    }
    if (isEntityEqual(senderEntity, receiverEntity)) {
      revert("You can't convert your own temperature to velocity");
    } else {
      // for each receiver position
      // call moveWithAgent
      // using the sender entity
      // this wont be an agent though
      VoxelEntity memory workingEntity = receiverEntity;
      // bytes32 voxelTypeId = getVoxelTypeId(callerAddress, workingEntity);
      VoxelCoord memory workingCoord = receiverCoord;
      for (uint i = 0; i < receiverPositionDelta.length; i++) {
        (bool success, bytes memory returnData) = callerAddress.call(
          abi.encodeWithSignature(
            "moveWithAgent(bytes32,(int32,int32,int32),(int32,int32,int32),(uint32,bytes32))",
            getVoxelTypeId(callerAddress, workingEntity),
            workingCoord,
            receiverPositionDelta[i],
            senderEntity
          )
        );
        if (success && returnData.length > 0) {
          console.log("move success");
          (, VoxelEntity memory newEntity) = abi.decode(returnData, (VoxelEntity, VoxelEntity));
          workingEntity = newEntity;
          // The entity could have been moved some place else, besides the new coord
          // so we need to update the working coord
          if (!voxelCoordsAreEqual(getVoxelCoordStrict(callerAddress, newEntity), receiverPositionDelta[i])) {
            // this means some collision happened which caused other movements
            // for now we just stop the loop
            break;
          }
          workingCoord = receiverPositionDelta[i];
        } else {
          console.log("move failed");
          // Could not move, so we break out of the loop
          break;
        }
      }
    }
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
    require(senderStaminaDelta >= 0, "Stamina delta must be positive");
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
      int32 receiverVelocityDeltaX = currentVelocity.x > 0 ? receiverVelocityDelta.x : -receiverVelocityDelta.x;
      uint256 resourceRequiredX = calculateResourceRequired(currentVelocity.x, receiverVelocityDeltaX, bodyMass);
      int32 receiverVelocityDeltaY = currentVelocity.y > 0 ? receiverVelocityDelta.y : -receiverVelocityDelta.y;
      uint256 resourceRequiredY = calculateResourceRequired(currentVelocity.y, receiverVelocityDeltaY, bodyMass);
      int32 receiverVelocityDeltaZ = currentVelocity.z > 0 ? receiverVelocityDelta.z : -receiverVelocityDelta.z;
      uint256 resourceRequiredZ = calculateResourceRequired(currentVelocity.z, receiverVelocityDeltaZ, bodyMass);
      resourceRequired = resourceRequiredX + resourceRequiredY + resourceRequiredZ;
    }
    uint256 currentStamina = Stamina.get(callerAddress, senderEntity.scale, senderEntity.entityId);
    require(currentStamina >= resourceRequired, "Not enough stamina to spend");
    Stamina.set(callerAddress, senderEntity.scale, senderEntity.entityId, currentStamina - resourceRequired);
    IWorld(_world()).fluxEnergy(false, callerAddress, receiverEntity, resourceRequired);
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
    // TODO: make this only callable by the simulator
    address callerAddress = super.getCallerAddress();
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId)),
      "Old entity does not exist"
    );
    EntityData memory oldEntityData;
    oldEntityData.mass = Mass.get(callerAddress, oldEntity.scale, oldEntity.entityId);
    (VoxelCoord memory newVelocity, uint256 resourceRequired) = calculateNewVelocity(
      callerAddress,
      oldCoord,
      newCoord,
      oldEntity,
      oldEntityData.mass
    );
    MovementResource resourceToConsume = hasKey(
      StaminaTableId,
      Stamina.encodeKeyTuple(callerAddress, actingEntity.scale, actingEntity.entityId)
    )
      ? MovementResource.Stamina
      : MovementResource.Temperature;
    oldEntityData.resource = resourceToConsume == MovementResource.Stamina
      ? Stamina.get(callerAddress, actingEntity.scale, actingEntity.entityId)
      : Temperature.get(callerAddress, actingEntity.scale, actingEntity.entityId);
    require(resourceRequired <= oldEntityData.resource, "Not enough resources to move.");

    if (hasKey(MassTableId, Mass.encodeKeyTuple(callerAddress, newEntity.scale, newEntity.entityId))) {
      require(
        Mass.get(callerAddress, newEntity.scale, newEntity.entityId) == 0,
        "Cannot move on top of an entity with mass"
      );
    } else {
      initTerrainEntity(callerAddress, oldEntity.scale, newCoord, newEntity);
    }
    oldEntityData.energy = Energy.get(callerAddress, oldEntity.scale, oldEntity.entityId);
    uint256 resourceInOldEntity = resourceToConsume == MovementResource.Stamina
      ? Stamina.get(callerAddress, oldEntity.scale, oldEntity.entityId)
      : Temperature.get(callerAddress, oldEntity.scale, oldEntity.entityId);

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
    Mass.set(callerAddress, newEntity.scale, newEntity.entityId, oldEntityData.mass);
    Energy.set(callerAddress, newEntity.scale, newEntity.entityId, oldEntityData.energy);
    Velocity.set(callerAddress, newEntity.scale, newEntity.entityId, block.number, abi.encode(newVelocity));
    // VoxelEntity memory newActingEntity = actingEntity;
    if (isEntityEqual(oldEntity, actingEntity)) {
      // newActingEntity = newEntity; // moving yourself, so update the acting entity
      if (resourceToConsume == MovementResource.Stamina) {
        Stamina.set(callerAddress, newEntity.scale, newEntity.entityId, oldEntityData.resource - resourceRequired);
      } else {
        Temperature.set(callerAddress, newEntity.scale, newEntity.entityId, oldEntityData.resource - resourceRequired);
      }
    } else {
      if (hasKey(StaminaTableId, Stamina.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
        Stamina.set(callerAddress, newEntity.scale, newEntity.entityId, resourceInOldEntity);
      }
      if (hasKey(TemperatureTableId, Temperature.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
        Temperature.set(callerAddress, newEntity.scale, newEntity.entityId, resourceInOldEntity);
      }
      if (resourceToConsume == MovementResource.Stamina) {
        Stamina.set(
          callerAddress,
          actingEntity.scale,
          actingEntity.entityId,
          oldEntityData.resource - resourceRequired
        );
      } else {
        Temperature.set(
          callerAddress,
          actingEntity.scale,
          actingEntity.entityId,
          oldEntityData.resource - resourceRequired
        );
      }
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
  ) internal pure returns (uint256) {
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
