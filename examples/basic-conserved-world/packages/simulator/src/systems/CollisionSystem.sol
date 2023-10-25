// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
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

contract CollisionSystem is System {
  function onCollision(
    address callerAddress,
    VoxelEntity memory centerVoxelEntity,
    VoxelEntity memory actingEntity
  ) public returns (VoxelEntity memory) {
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
      VoxelCoord memory currentVelocity = getVelocity(callerAddress, useCollisionData.entity);
      (VoxelCoord memory newVelocity, bytes32[] memory neighbourEntities, ) = calculateVelocityAfterCollision(
        callerAddress,
        getVoxelCoordStrict(callerAddress, useCollisionData.entity),
        useCollisionData.entity,
        currentVelocity
      );
      // Update collision data
      useCollisionData.oldVelocity = currentVelocity;
      useCollisionData.newVelocity = newVelocity;
      centerEntitiesToCheckStack[useStackIdx] = useCollisionData;

      if (useStackIdx == 0 || !voxelCoordsAreEqual(currentVelocity, newVelocity)) {
        if (useStackIdx > 0) {
          // Note: we don't update the first one (index == 0), because it's already been applied in the initial move
          Velocity.setVelocity(
            callerAddress,
            useCollisionData.entity.scale,
            useCollisionData.entity.entityId,
            abi.encode(newVelocity)
          );
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
            if (!isAlreadyInStack && Mass.get(callerAddress, useCollisionData.entity.scale, neighbourEntities[i]) > 0) {
              centerEntitiesToCheckStackIdx++;
              require(
                centerEntitiesToCheckStackIdx < MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH,
                "PhysicsSystem: Reached max depth for collisions"
              );
              CollisionData memory neighbourCollisionData;
              neighbourCollisionData.entity = VoxelEntity({
                scale: useCollisionData.entity.scale,
                entityId: neighbourEntities[i]
              });
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
        // go through each axis, x, y, z and for each one figure out the new coord by adding the unit amount (ie 1), and make the move event call
        VoxelCoord memory workingCoord = getVoxelCoordStrict(callerAddress, workingEntity);
        {
          VoxelCoord memory deltaVelocity = sub(collisionData.newVelocity, collisionData.oldVelocity);
          bytes32 voxelTypeId = getVoxelTypeId(callerAddress, workingEntity);
          // TODO: What is the optimal order in which to try these?
          (workingCoord, actingEntity) = tryToReachTargetVelocity(
            callerAddress,
            voxelTypeId,
            actingEntity,
            workingCoord,
            deltaVelocity.x,
            CoordDirection.X
          );
          (workingCoord, actingEntity) = tryToReachTargetVelocity(
            callerAddress,
            voxelTypeId,
            actingEntity,
            workingCoord,
            deltaVelocity.y,
            CoordDirection.Y
          );
          (workingCoord, actingEntity) = tryToReachTargetVelocity(
            callerAddress,
            voxelTypeId,
            actingEntity,
            workingCoord,
            deltaVelocity.z,
            CoordDirection.Z
          );
        }
        if (isEntityEqual(centerVoxelEntity, workingEntity)) {
          // this means the center entity was moved, so we need to update it's entity
          // it should be at the last working coord now
          centerVoxelEntity = VoxelEntity({
            scale: centerVoxelEntity.scale,
            entityId: getEntityAtCoord(callerAddress, centerVoxelEntity.scale, workingCoord)
          });
        }
      }
    }

    return centerVoxelEntity;
  }

  function tryToReachTargetVelocity(
    address callerAddress,
    bytes32 voxelTypeId,
    VoxelEntity memory actingEntity,
    VoxelCoord memory startingCoord,
    int32 vDelta,
    CoordDirection direction
  ) internal returns (VoxelCoord memory workingCoord, VoxelEntity memory newActingEntity) {
    workingCoord = startingCoord;
    newActingEntity = actingEntity;

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
        // Try moving
        console.log("Trying to move post-collision");
        (bool success, bytes memory returnData) = callerAddress.call(
          abi.encodeWithSignature(
            "moveWithAgent(bytes32,(int32,int32,int32),(int32,int32,int32),(uint32,bytes32))",
            voxelTypeId,
            workingCoord,
            newCoord,
            newActingEntity
          )
        );
        if (success && returnData.length > 0) {
          console.log("move success");
          VoxelEntity memory newEntity;
          {
            VoxelEntity memory oldEntity;
            (oldEntity, newEntity) = abi.decode(returnData, (VoxelEntity, VoxelEntity));
            if (isEntityEqual(oldEntity, newActingEntity)) {
              newActingEntity = newEntity;
            }
          }
          // The entity could have been moved some place else, besides the new coord
          // so we need to update the working coord
          workingCoord = getVoxelCoordStrict(callerAddress, newEntity);
        } else {
          console.log("move failed");
          // Could not move, so we break out of the loop
          // TODO: In a future iteration, we should dissipate energy from the velocity force that could not be applied
          break;
        }
      }
    }
    return (workingCoord, newActingEntity);
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
          // Check to see if this neighbour has a velocity and is having an impact on us
          VoxelCoord memory neighbourVelocity = getVelocity(
            callerAddress,
            VoxelEntity({ scale: centerVoxelEntity.scale, entityId: neighbourEntities[i] })
          );
          relativePosition = sub(centerCoord, neighbourCoords[i]);
          dotProduct = dot(neighbourVelocity, relativePosition);
        } // else it's velocity would be zero
      }
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
      VoxelCoord memory impulse = mulScalar(relativeVelocity, impulseFactor);
      // Add to total impulse
      total_impulse = add(total_impulse, impulse);
    }

    VoxelCoord memory delta_velocity = divScalar(total_impulse, mass_primary);
    new_primary_velocity = add(primaryVelocity, delta_velocity);
    return (new_primary_velocity, neighbourEntities, neighbourCoords);
  }
}
