// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Velocity, VelocityData, VelocityTableId } from "@tenet-simulator/src/codegen/tables/Velocity.sol";

import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { ITerrainSystem } from "@tenet-base-world/src/codegen/world/ITerrainSystem.sol";
import { IBuildSystem } from "@tenet-base-world/src/codegen/world/IBuildSystem.sol";
import { IMoveSystem } from "@tenet-base-world/src/codegen/world/IMoveSystem.sol";

import { getVelocity } from "@tenet-simulator/src/Utils.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getVoxelCoordStrict, getEntityIdFromObjectEntityId, getVonNeumannNeighbourEntities } from "@tenet-base-world/src/Utils.sol";
import { isZeroCoord, voxelCoordsAreEqual, dot, mulScalar, divScalar, add, sub } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { abs, absInt32 } from "@tenet-utils/src/MathUtils.sol";
import { WORLD_MOVE_SIG } from "@tenet-base-world/src/Constants.sol";
import { uint256ToInt32, int256ToUint256, safeSubtract } from "@tenet-utils/src/TypeUtils.sol";

struct CollisionData {
  bytes32 objectEntityId;
  VoxelCoord oldVelocity;
  VoxelCoord newVelocity;
}

enum CoordDirection {
  X,
  Y,
  Z
}

uint256 constant NUM_MAX_COLLISIONS_UPDATE_DEPTH = 50;

contract CollisionRuleSystem is System {
  function onCollision(
    address worldAddress,
    bytes32 centerObjectEntityId,
    bytes32 actingObjectEntityId
  ) public returns (bytes32) {
    CollisionData[] memory centerEntitiesToCheckQueue = new CollisionData[](NUM_MAX_COLLISIONS_UPDATE_DEPTH);
    uint256 centerEntitiesToCheckQueueIdx = 0;
    uint256 useQueueIdx = 0;

    CollisionData memory centerCollisionData;
    centerCollisionData.objectEntityId = centerObjectEntityId;

    // start with the center entity
    centerEntitiesToCheckQueue[centerEntitiesToCheckQueueIdx] = centerCollisionData;
    useQueueIdx = centerEntitiesToCheckQueueIdx;

    // Keep looping until there is no neighbour to process or we reached max depth
    while (useQueueIdx < NUM_MAX_COLLISIONS_UPDATE_DEPTH) {
      CollisionData memory useCollisionData = centerEntitiesToCheckQueue[useQueueIdx];
      useCollisionData.oldVelocity = getVelocity(worldAddress, useCollisionData.objectEntityId);
      (VoxelCoord memory newVelocity, bytes32[] memory neighbourObjectEntities, ) = calculateVelocityAfterCollision(
        worldAddress,
        getVoxelCoordStrict(
          IStore(worldAddress),
          getEntityIdFromObjectEntityId(IStore(worldAddress), useCollisionData.objectEntityId)
        ),
        useCollisionData.objectEntityId,
        useCollisionData.oldVelocity
      );
      // Update collision data
      useCollisionData.newVelocity = newVelocity;
      centerEntitiesToCheckQueue[useQueueIdx] = useCollisionData;

      if (useQueueIdx == 0 || !voxelCoordsAreEqual(useCollisionData.oldVelocity, newVelocity)) {
        if (useQueueIdx > 0) {
          // Note: we don't update the first one (index == 0), because it's already been applied in the initial move
          Velocity.setVelocity(worldAddress, useCollisionData.objectEntityId, abi.encode(newVelocity));
        }

        // Go through neighbours and add them to the stack for updates
        for (uint256 i = 0; i < neighbourObjectEntities.length; i++) {
          if (uint256(neighbourObjectEntities[i]) != 0) {
            // Check if the neighbour is already in the stack
            bool isAlreadyInQueue = false;
            for (uint256 j = 0; j <= centerEntitiesToCheckQueueIdx; j++) {
              if (centerEntitiesToCheckQueue[j].objectEntityId == neighbourObjectEntities[i]) {
                isAlreadyInQueue = true;
                break;
              }
            }
            // If the mass is 0, then we don't need to check it, since you can't collide with it
            if (!isAlreadyInQueue && Mass.get(worldAddress, neighbourObjectEntities[i]) > 0) {
              centerEntitiesToCheckQueueIdx++;
              require(
                centerEntitiesToCheckQueueIdx < NUM_MAX_COLLISIONS_UPDATE_DEPTH,
                "CollisionRuleSystem: Reached max update depth for collisions"
              );
              CollisionData memory neighbourCollisionData;
              neighbourCollisionData.objectEntityId = neighbourObjectEntities[i];
              centerEntitiesToCheckQueue[centerEntitiesToCheckQueueIdx] = neighbourCollisionData;
            }
          }
        }
      }

      // at this point, we've consumed the top of the stack,
      // so we can pop it, in this case, we just increment the stack index
      if (centerEntitiesToCheckQueueIdx > useQueueIdx) {
        useQueueIdx++;
      } else {
        // this means we didnt any any updates, so we can break out of the loop
        break;
      }
    }

    // Go through the stack, and reset all the velocities
    for (uint256 i = 0; i <= centerEntitiesToCheckQueueIdx; i++) {
      CollisionData memory collisionData = centerEntitiesToCheckQueue[i];
      if (!voxelCoordsAreEqual(collisionData.oldVelocity, collisionData.newVelocity)) {
        Velocity.setVelocity(worldAddress, collisionData.objectEntityId, abi.encode(collisionData.oldVelocity));
      }
    }

    // Go through the stack in reverse order and if old and new velocity are different, create move events accordingly
    // TODO: check for overflow
    bytes32 centerEntityId = getEntityIdFromObjectEntityId(IStore(worldAddress), centerObjectEntityId);
    for (uint256 i = centerEntitiesToCheckQueueIdx + 1; i > 0; i--) {
      CollisionData memory collisionData = centerEntitiesToCheckQueue[i - 1];
      if (!voxelCoordsAreEqual(collisionData.oldVelocity, collisionData.newVelocity)) {
        bytes32 workingEntityId = getEntityIdFromObjectEntityId(IStore(worldAddress), collisionData.objectEntityId);
        // go through each axis, x, y, z and for each one figure out the new coord by adding the unit amount (ie 1), and make the move event call
        VoxelCoord memory workingCoord = getVoxelCoordStrict(IStore(worldAddress), workingEntityId);
        {
          VoxelCoord memory deltaVelocity = sub(collisionData.newVelocity, collisionData.oldVelocity);
          bytes32 objectTypeId = ObjectType.get(IStore(worldAddress), workingEntityId);
          // TODO: What is the optimal order in which to try these?
          (workingCoord, actingObjectEntityId) = tryToReachTargetVelocity(
            worldAddress,
            objectTypeId,
            actingObjectEntityId,
            workingCoord,
            deltaVelocity.x,
            CoordDirection.X
          );
          (workingCoord, actingObjectEntityId) = tryToReachTargetVelocity(
            worldAddress,
            objectTypeId,
            actingObjectEntityId,
            workingCoord,
            deltaVelocity.y,
            CoordDirection.Y
          );
          (workingCoord, actingObjectEntityId) = tryToReachTargetVelocity(
            worldAddress,
            objectTypeId,
            actingObjectEntityId,
            workingCoord,
            deltaVelocity.z,
            CoordDirection.Z
          );
        }
        if (centerEntityId == workingEntityId) {
          // this means the center entity was moved, so we need to update it's entity
          // it should be at the last working coord now
          centerEntityId = getEntityAtCoord(IStore(worldAddress), workingCoord);
        }
      }
    }

    return centerEntityId;
  }

  function tryToReachTargetVelocity(
    address worldAddress,
    bytes32 objectTypeId,
    bytes32 actingObjectEntityId,
    VoxelCoord memory startingCoord,
    int32 vDelta,
    CoordDirection direction
  ) internal returns (VoxelCoord memory workingCoord, bytes32 newActingObjectEntityId) {
    workingCoord = startingCoord;
    newActingObjectEntityId = actingObjectEntityId;

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
    for (int32 i = 0; i < absInt32(vDelta); i++) {
      {
        // Try moving
        // Note: we can't use IMoveSystem here because we need to safe call it
        (bool moveSuccess, bytes memory moveReturnData) = worldAddress.call(
          abi.encodeWithSignature(
            WORLD_MOVE_SIG,
            actingObjectEntityId,
            objectTypeId,
            workingCoord,
            add(workingCoord, deltaVelocity)
          )
        );
        if (moveSuccess && moveReturnData.length > 0) {
          bytes32 newEntityId;
          {
            bytes32 oldEntityId;
            // TODO: Should do safe decoding here
            (oldEntityId, newEntityId) = abi.decode(moveReturnData, (bytes32, bytes32));
            if (ObjectEntity.get(IStore(worldAddress), oldEntityId) == newActingObjectEntityId) {
              newActingObjectEntityId = ObjectEntity.get(IStore(worldAddress), newEntityId);
            }
          }
          // The entity could have been moved some place else, besides the new coord
          // so we need to update the working coord
          workingCoord = getVoxelCoordStrict(IStore(worldAddress), newEntityId);
        } else {
          // Could not move, so we break out of the loop
          // TODO: In a future iteration, we should dissipate energy from the velocity force that could not be applied
          break;
        }
      }
    }
    return (workingCoord, newActingObjectEntityId);
  }

  function calculateVelocityAfterCollision(
    address worldAddress,
    VoxelCoord memory centerCoord,
    bytes32 centerObjectEntityId,
    VoxelCoord memory primaryVelocity
  )
    internal
    returns (
      VoxelCoord memory newPrimaryVelocity,
      bytes32[] memory neighbourObjectEntities,
      VoxelCoord[] memory neighbourCoords
    )
  {
    bytes32[] memory neighbourEntities;
    (neighbourEntities, neighbourCoords) = getVonNeumannNeighbourEntities(
      IStore(worldAddress),
      getEntityIdFromObjectEntityId(IStore(worldAddress), centerObjectEntityId)
    );
    neighbourObjectEntities = new bytes32[](neighbourEntities.length);

    bytes32[] memory collidingObjectEntities = new bytes32[](neighbourEntities.length);

    // We first compute the dot product to figure out for which coords, do we need to run the collison formula
    for (uint256 i = 0; i < neighbourCoords.length; i++) {
      VoxelCoord memory relativePosition = sub(neighbourCoords[i], centerCoord);
      int dotProduct = dot(primaryVelocity, relativePosition);
      if (dotProduct <= 0) {
        if (uint256(neighbourEntities[i]) != 0) {
          // Check to see if this neighbour has a velocity and is having an impact on us
          VoxelCoord memory neighbourVelocity = getVelocity(
            worldAddress,
            ObjectEntity.get(IStore(worldAddress), neighbourEntities[i])
          );
          relativePosition = sub(centerCoord, neighbourCoords[i]);
          dotProduct = dot(neighbourVelocity, relativePosition);
        } // else it's velocity would be zero
      }
      if (dotProduct > 0) {
        // this means the primary object is moving towards the neighbour
        if (uint256(neighbourEntities[i]) == 0) {
          ObjectProperties memory emptyProperties;
          ObjectProperties memory terrainProperties = ITerrainSystem(worldAddress).getTerrainObjectProperties(
            neighbourCoords[i],
            emptyProperties
          );
          if (terrainProperties.mass == 0) {
            // can only collide with terrain that has mass
            continue;
          }
          // create the entities that don't exist from the terrain
          bytes32 newTerrainEntityId = IBuildSystem(worldAddress).buildTerrain(
            bytes32(0), // No acting object entity, since this is the simulator calling it
            neighbourCoords[i]
          );
          neighbourObjectEntities[i] = ObjectEntity.get(IStore(worldAddress), newTerrainEntityId);
        } else {
          neighbourObjectEntities[i] = ObjectEntity.get(IStore(worldAddress), neighbourEntities[i]);
        }

        if (Mass.get(worldAddress, neighbourObjectEntities[i]) == 0) {
          // can only collide with terrain that has mass
          continue;
        }
        collidingObjectEntities[i] = neighbourObjectEntities[i];
      } else {
        if (uint256(neighbourEntities[i]) != 0) {
          neighbourObjectEntities[i] = ObjectEntity.get(IStore(worldAddress), neighbourEntities[i]);
        }
      }
    }

    int32 massPrimary = uint256ToInt32(Mass.get(worldAddress, centerObjectEntityId));
    if (massPrimary == 0) {
      revert("CollisionRuleSystem: Trying to collide with an object that has no mass");
    }

    // Now we run the collision formula for each of the colliding entities
    VoxelCoord memory totalImpulse = VoxelCoord({ x: 0, y: 0, z: 0 });
    for (uint256 i = 0; i < collidingObjectEntities.length; i++) {
      if (uint256(collidingObjectEntities[i]) == 0) {
        continue;
      }
      // Calculate the impulse of this neighbour
      VoxelCoord memory relativeVelocity = sub(getVelocity(worldAddress, collidingObjectEntities[i]), primaryVelocity);
      int32 massNeighbour = uint256ToInt32(Mass.get(worldAddress, collidingObjectEntities[i]));
      int32 impulseFactor = (2 * massNeighbour) / (massPrimary + massNeighbour);
      VoxelCoord memory impulse = mulScalar(relativeVelocity, impulseFactor);
      // Add to total impulse
      totalImpulse = add(totalImpulse, impulse);
    }

    VoxelCoord memory deltaVelocity = divScalar(totalImpulse, massPrimary);
    newPrimaryVelocity = add(primaryVelocity, deltaVelocity);
    return (newPrimaryVelocity, neighbourObjectEntities, neighbourCoords);
  }
}
