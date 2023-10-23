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

struct CollisionData {
  VoxelEntity entity;
  VoxelCoord oldVelocity;
  VoxelCoord newVelocity;
}

enum CoordDirection {
  X,
  Y,
  Z
}

contract VelocitySystem is SimHandler {
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

  function onCollision(
    address callerAddress,
    VoxelEntity memory centerVoxelEntity,
    VoxelEntity memory actingEntity
  ) internal {
    console.log("onCollision");
    console.logBytes32(centerVoxelEntity.entityId);
    CollisionData[] memory centerEntitiesToCheckStack = new CollisionData[](MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH);
    uint256 centerEntitiesToCheckStackIdx = 0;
    uint256 useStackIdx = 0;

    CollisionData memory centerCollisionData;
    centerCollisionData.entity = centerVoxelEntity;

    // start with the center entity
    centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = centerCollisionData;
    useStackIdx = centerEntitiesToCheckStackIdx;

    // Keep looping until there is no neighbour to process or we reached max depth
    while (useStackIdx < MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH) {
      CollisionData memory useCollisionData = centerEntitiesToCheckStack[useStackIdx];
      VoxelEntity memory useEntity = useCollisionData.entity;
      VoxelCoord memory currentVelocity = getVelocity(callerAddress, useEntity);
      (VoxelCoord memory newVelocity, bytes32[] memory neighbourEntities, ) = calculateVelocityAfterCollision(
        callerAddress,
        getVoxelCoordStrict(callerAddress, useEntity),
        useEntity,
        currentVelocity
      );
      // Update collision data
      useCollisionData.oldVelocity = currentVelocity;
      useCollisionData.newVelocity = newVelocity;
      centerEntitiesToCheckStack[useStackIdx] = useCollisionData;

      if (useStackIdx == 0 || !voxelCoordsAreEqual(currentVelocity, newVelocity)) {
        if (useStackIdx > 0) {
          // Note: we don't update the first one (index == 0), because it's already been applied in the initial move
          Velocity.setVelocity(callerAddress, useEntity.scale, useEntity.entityId, abi.encode(newVelocity));
        }

        // Go through neighbours and add them to the stack for updates
        for (uint8 i = 0; i < neighbourEntities.length; i++) {
          if (uint256(neighbourEntities[i]) != 0) {
            // Check if the neighbour is already in the stack
            bool isAlreadyInStack = false;
            for (uint8 j = 0; j <= centerEntitiesToCheckStackIdx; j++) {
              if (centerEntitiesToCheckStack[j].entity.entityId == neighbourEntities[i]) {
                isAlreadyInStack = true;
                break;
              }
            }
            if (!isAlreadyInStack && Mass.get(callerAddress, useEntity.scale, neighbourEntities[i]) > 0) {
              console.log("adding neighbur");
              console.logBytes32(neighbourEntities[i]);
              centerEntitiesToCheckStackIdx++;
              require(
                centerEntitiesToCheckStackIdx < MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH,
                "PhysicsSystem: Reached max depth for collisions"
              );
              CollisionData memory neighbourCollisionData;
              neighbourCollisionData.entity = VoxelEntity({ scale: useEntity.scale, entityId: neighbourEntities[i] });
              centerEntitiesToCheckStack[centerEntitiesToCheckStackIdx] = neighbourCollisionData;
            }
          }
        }
      }

      // at this point, we've consumed the top of the stack,
      // so we can pop it, in this case, we just increment the stack index
      if (centerEntitiesToCheckStackIdx > useStackIdx) {
        useStackIdx++;
      } else {
        // this means we didnt any any updates, so we can break out of the loop
        break;
      }
    }

    // Go through the stack, and reset all the velocities
    for (uint256 i = 0; i <= centerEntitiesToCheckStackIdx; i++) {
      CollisionData memory collisionData = centerEntitiesToCheckStack[i];
      if (!voxelCoordsAreEqual(collisionData.oldVelocity, collisionData.newVelocity)) {
        Velocity.setVelocity(
          callerAddress,
          collisionData.entity.scale,
          collisionData.entity.entityId,
          abi.encode(collisionData.oldVelocity)
        );
      }
    }

    // Go through the stack in reverse order and if old and new velocity are different, create move events accordingly
    // TODO: check for overflow
    for (uint256 i = centerEntitiesToCheckStackIdx + 1; i > 0; i--) {
      CollisionData memory collisionData = centerEntitiesToCheckStack[i - 1];
      if (!voxelCoordsAreEqual(collisionData.oldVelocity, collisionData.newVelocity)) {
        VoxelEntity memory workingEntity = collisionData.entity;
        VoxelCoord memory workingCoord = getVoxelCoordStrict(callerAddress, workingEntity);
        VoxelCoord memory deltaVelocity = sub(collisionData.newVelocity, collisionData.oldVelocity);
        // go through each axis, x, y, z and for each one figure out the new coord by adding the unit amount (ie 1), and make the move event call
        bytes32 voxelTypeId = getVoxelTypeId(callerAddress, workingEntity);
        // TODO: What is the optimal order in which to try these?
        workingCoord = tryToReachTargetVelocity(
          callerAddress,
          voxelTypeId,
          actingEntity,
          workingCoord,
          deltaVelocity.x,
          CoordDirection.X
        );
        workingCoord = tryToReachTargetVelocity(
          callerAddress,
          voxelTypeId,
          actingEntity,
          workingCoord,
          deltaVelocity.y,
          CoordDirection.Y
        );
        workingCoord = tryToReachTargetVelocity(
          callerAddress,
          voxelTypeId,
          actingEntity,
          workingCoord,
          deltaVelocity.z,
          CoordDirection.Z
        );
      }
    }
  }

  function tryToReachTargetVelocity(
    address callerAddress,
    bytes32 voxelTypeId,
    VoxelEntity memory actingEntity,
    VoxelCoord memory startingCoord,
    int32 vDelta,
    CoordDirection direction
  ) internal returns (VoxelCoord memory workingCoord) {
    workingCoord = startingCoord;

    // Determine which dimension to move based on the direction
    VoxelCoord memory deltaVelocity = VoxelCoord({ x: 0, y: 0, z: 0 });
    if (direction == CoordDirection.X) {
      deltaVelocity.x = (vDelta > 0) ? int32(1) : int32(-1);
    } else if (direction == CoordDirection.Y) {
      deltaVelocity.y = (vDelta > 0) ? int32(1) : int32(-1);
    } else if (direction == CoordDirection.Z) {
      deltaVelocity.z = (vDelta > 0) ? int32(1) : int32(-1);
    }

    // Create move events based on the delta
    for (int256 i = 0; i < absInt32(vDelta); i++) {
      {
        VoxelCoord memory newCoord = add(workingCoord, deltaVelocity);
        console.log("moving to new coord");
        console.logBytes32(actingEntity.entityId);
        console.logInt(workingCoord.x);
        console.logInt(workingCoord.y);
        console.logInt(workingCoord.z);
        console.logInt(newCoord.x);
        console.logInt(newCoord.y);
        console.logInt(newCoord.z);
        // Try moving
        (bool success, bytes memory returnData) = callerAddress.call(
          abi.encodeWithSignature(
            "moveWithAgent(bytes32,(int32,int32,int32),(int32,int32,int32),(uint32,bytes32))",
            voxelTypeId,
            workingCoord,
            newCoord,
            actingEntity
          )
        );
        if (success && returnData.length > 0) {
          console.log("move success");
          (, VoxelEntity memory workingEntity) = abi.decode(returnData, (VoxelEntity, VoxelEntity));
          require(
            voxelCoordsAreEqual(getVoxelCoordStrict(callerAddress, workingEntity), newCoord),
            "PhysicsSystem: Move event failed"
          );
          workingCoord = newCoord;
        } else {
          console.log("move failed");
          // Could not move, so we break out of the loop
          // TODO: In a future iteration, we should dissipate energy from the velocity force that could not be applied
          break;
        }
      }
    }
    return workingCoord;
  }

  function calculateVelocityAfterCollision(
    address callerAddress,
    VoxelCoord memory centerCoord,
    VoxelEntity memory centerVoxelEntity,
    VoxelCoord memory primaryVelocity
  )
    internal
    returns (
      VoxelCoord memory new_primary_velocity,
      bytes32[] memory neighbourEntities,
      VoxelCoord[] memory neighbourCoords
    )
  {
    (neighbourEntities, neighbourCoords) = getNeighbourEntities(callerAddress, centerVoxelEntity);

    bytes32[] memory collidingEntities = new bytes32[](neighbourEntities.length);

    // We first compute the dot product to figure out for which coords, do we need to run the collison formula
    for (uint8 i = 0; i < neighbourCoords.length; i++) {
      VoxelCoord memory relativePosition = sub(neighbourCoords[i], centerCoord);
      int dotProduct = dot(primaryVelocity, relativePosition);
      if (dotProduct <= 0) {
        if (uint256(neighbourEntities[i]) != 0) {
          console.log("impact on us");
          // Check to see if this neighbour has a velocity and is having an impact on us
          VoxelCoord memory neighbourVelocity = getVelocity(
            callerAddress,
            VoxelEntity({ scale: centerVoxelEntity.scale, entityId: neighbourEntities[i] })
          );
          relativePosition = sub(centerCoord, neighbourCoords[i]);
          dotProduct = dot(neighbourVelocity, relativePosition);
        } // else it's velocity would be zero
      }
      console.log("dot product");
      console.logInt(dotProduct);
      if (dotProduct > 0) {
        // this means the primary voxel is moving towards the neighbour
        if (uint256(neighbourEntities[i]) == 0) {
          if (getTerrainMass(callerAddress, centerVoxelEntity.scale, neighbourCoords[i]) == 0) {
            // can only collide with terrain that has mass
            collidingEntities[i] = 0;
            continue;
          }
          // create the entities that don't exist from the terrain
          VoxelEntity memory newTerrainEntity = createTerrainEntity(
            callerAddress,
            centerVoxelEntity.scale,
            neighbourCoords[i]
          );
          neighbourEntities[i] = newTerrainEntity.entityId;
        }

        if (Mass.get(callerAddress, centerVoxelEntity.scale, neighbourEntities[i]) == 0) {
          // can only collide with terrain that has mass
          collidingEntities[i] = 0;
          continue;
        }
        collidingEntities[i] = neighbourEntities[i];
      } else {
        collidingEntities[i] = 0;
      }
    }

    int32 mass_primary = uint256ToInt32(Mass.get(callerAddress, centerVoxelEntity.scale, centerVoxelEntity.entityId));
    console.log("mass_primary");
    console.logBytes32(centerVoxelEntity.entityId);
    console.logInt(centerCoord.x);
    console.logInt(centerCoord.y);
    console.logInt(centerCoord.z);
    console.logUint(Mass.get(callerAddress, centerVoxelEntity.scale, centerVoxelEntity.entityId));
    console.logInt(mass_primary);

    // Now we run the collision formula for each of the colliding entities
    VoxelCoord memory total_impulse = VoxelCoord({ x: 0, y: 0, z: 0 });
    for (uint8 i = 0; i < collidingEntities.length; i++) {
      if (uint256(collidingEntities[i]) == 0) {
        continue;
      }
      // Calculate the impulse of this neighbour
      VoxelCoord memory relativeVelocity = sub(
        getVelocity(callerAddress, VoxelEntity({ scale: centerVoxelEntity.scale, entityId: collidingEntities[i] })),
        primaryVelocity
      );
      int32 mass_neighbour = uint256ToInt32(Mass.get(callerAddress, centerVoxelEntity.scale, collidingEntities[i]));
      int32 impulseFactor = (2 * mass_neighbour) / (mass_primary + mass_neighbour);
      console.log("impulseFactor");
      console.logInt(impulseFactor);
      VoxelCoord memory impulse = mulScalar(relativeVelocity, impulseFactor);
      // Add to total impulse
      total_impulse = add(total_impulse, impulse);
    }

    VoxelCoord memory delta_velocity = divScalar(total_impulse, mass_primary);
    console.log("delta_velocity");
    console.logInt(delta_velocity.x);
    console.logInt(delta_velocity.y);
    console.logInt(delta_velocity.z);
    new_primary_velocity = add(primaryVelocity, delta_velocity);
    return (new_primary_velocity, neighbourEntities, neighbourCoords);
  }

  function velocityChange(
    VoxelEntity memory actingEntity,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    VoxelEntity memory oldEntity,
    VoxelEntity memory newEntity
  ) public {
    address callerAddress = super.getCallerAddress();
    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId)),
      "Old entity does not exist"
    );
    uint256 bodyMass = Mass.get(callerAddress, oldEntity.scale, oldEntity.entityId);
    console.log("velocityChange");
    console.logAddress(callerAddress);
    console.logBytes32(oldEntity.entityId);
    console.logBytes32(newEntity.entityId);
    console.logUint(bodyMass);
    (VoxelCoord memory newVelocity, uint256 resourceRequired) = calculateNewVelocity(
      callerAddress,
      oldCoord,
      newCoord,
      oldEntity,
      bodyMass
    );
    console.log("check stamina bro");
    console.logBytes32(actingEntity.entityId);
    uint256 staminaInActingEntity = Stamina.get(callerAddress, actingEntity.scale, actingEntity.entityId);
    console.logUint(staminaInActingEntity);
    console.logUint(resourceRequired);
    require(resourceRequired <= staminaInActingEntity, "Not enough stamina to move.");
    console.log("keep on going brr");

    if (hasKey(MassTableId, Mass.encodeKeyTuple(callerAddress, newEntity.scale, newEntity.entityId))) {
      console.log("entity got mass bro");
      require(
        Mass.get(callerAddress, newEntity.scale, newEntity.entityId) == 0,
        "Cannot move on top of an entity with mass"
      );
    } else {
      {
        uint256 terrainMass = getTerrainMass(callerAddress, oldEntity.scale, newCoord);
        console.log("terrian got mass bro");
        require(terrainMass == 0, "Cannot move on top of terrain with mass");
        Mass.set(callerAddress, newEntity.scale, newEntity.entityId, terrainMass);
      }
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
    uint256 energyInOldBlock = Energy.get(callerAddress, oldEntity.scale, oldEntity.entityId);
    uint256 staminaInOldEntity = Stamina.get(callerAddress, oldEntity.scale, oldEntity.entityId);

    console.log("set osme shit");
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

    console.log("flux flux flux");
    IWorld(_world()).fluxEnergy(
      false,
      callerAddress,
      newEntity,
      resourceRequired + Energy.get(callerAddress, newEntity.scale, newEntity.entityId)
    );

    // Update the new entity's energy and velocity
    Mass.set(callerAddress, newEntity.scale, newEntity.entityId, bodyMass);
    Energy.set(callerAddress, newEntity.scale, newEntity.entityId, energyInOldBlock);
    Velocity.set(callerAddress, newEntity.scale, newEntity.entityId, block.number, abi.encode(newVelocity));
    VoxelEntity memory newActingEntity = actingEntity;
    if (isEntityEqual(oldEntity, actingEntity)) {
      console.log("set stamina");
      newActingEntity = newEntity; // moving yourself, so update the acting entity
      Stamina.set(callerAddress, newEntity.scale, newEntity.entityId, staminaInActingEntity - resourceRequired);
    } else {
      if (hasKey(StaminaTableId, Stamina.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
        Stamina.set(callerAddress, newEntity.scale, newEntity.entityId, staminaInOldEntity);
      }
      Stamina.set(callerAddress, actingEntity.scale, actingEntity.entityId, staminaInActingEntity - resourceRequired);
    }

    onCollision(callerAddress, newEntity, newActingEntity);
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
