// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Health, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Velocity, VelocityData, VelocityTableId } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { GravityMetadata } from "@tenet-simulator/src/codegen/tables/GravityMetadata.sol";
import { MoveTrigger } from "@tenet-simulator/src/codegen/Types.sol";

import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { Position } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { ITerrainSystem } from "@tenet-base-world/src/codegen/world/ITerrainSystem.sol";
import { IBuildSystem } from "@tenet-base-world/src/codegen/world/IBuildSystem.sol";
import { IMineSystem } from "@tenet-base-world/src/codegen/world/IMineSystem.sol";
import { IMoveSystem } from "@tenet-base-world/src/codegen/world/IMoveSystem.sol";

import { getVelocity, callWorldMove } from "@tenet-simulator/src/Utils.sol";
import { VoxelCoord, ObjectProperties, BlockDirection } from "@tenet-utils/src/Types.sol";
import { positionDataToVoxelCoord, getEntityAtCoord, getVoxelCoordStrict, getEntityIdFromObjectEntityId, getVonNeumannNeighbourEntities } from "@tenet-base-world/src/Utils.sol";
import { isZeroCoord, voxelCoordsAreEqual, dot, mulScalar, divScalar, add, sub, calculateBlockDirection, getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { abs, absInt32 } from "@tenet-utils/src/MathUtils.sol";
import { uint256ToInt32, int256ToUint256, safeSubtract } from "@tenet-utils/src/TypeUtils.sol";
import { GRAVITY_DAMAGE } from "@tenet-simulator/src/Constants.sol";

contract GravityRuleSystem is System {
  function applyGravity(
    address worldAddress,
    VoxelCoord memory eventCoord,
    bytes32 eventObjectEntityId,
    bytes32 actingObjectEntityId
  ) public returns (bytes32) {
    uint256 currentMass = Mass.get(worldAddress, eventObjectEntityId);

    bytes32 eventEntityId = getEntityAtCoord(IStore(worldAddress), eventCoord);
    if (currentMass == 0) {
      // if the current mass is 0, then we need to apply gravity to all the blocks around it
      (bytes32[] memory neighbourEntities, VoxelCoord[] memory neighbourCoords) = getVonNeumannNeighbourEntities(
        IStore(worldAddress),
        eventEntityId
      );
      for (uint256 i = 0; i < neighbourEntities.length; i++) {
        BlockDirection blockDirection = calculateBlockDirection(eventCoord, neighbourCoords[i]);
        if (blockDirection == BlockDirection.Down || blockDirection == BlockDirection.None) {
          continue;
        }

        if (neighbourEntities[i] != bytes32(0)) {
          bytes32 neighbourObjectEntityId = ObjectEntity.get(IStore(worldAddress), neighbourEntities[i]);
          BlockDirection neighbourSupportDirection = GravityMetadata.get(worldAddress, neighbourObjectEntityId);
          if (blockDirection == neighbourSupportDirection) {
            // reset the gravity metadata for the neighbour
            GravityMetadata.set(worldAddress, neighbourObjectEntityId, BlockDirection.None);
          }
        }

        runGravity(worldAddress, neighbourCoords[i], neighbourEntities[i], actingObjectEntityId);
      }
      return eventEntityId;
    } else {
      // else, the gravity is applied to the current block
      return runGravity(worldAddress, eventCoord, eventEntityId, actingObjectEntityId);
    }
  }

  function runGravity(
    address worldAddress,
    VoxelCoord memory applyCoord,
    bytes32 applyEntityId,
    bytes32 actingObjectEntityId
  ) public returns (bytes32) {
    if (
      supportingBottomBlockExists(worldAddress, applyEntityId, applyCoord) ||
      supportingSideBlockExists(worldAddress, applyEntityId, applyCoord)
    ) {
      return applyEntityId;
    }
    if (applyEntityId == bytes32(0)) {
      applyEntityId = IBuildSystem(worldAddress).buildTerrain(
        bytes32(0), // No acting object entity, since this is the simulator calling it
        applyCoord
      );
    }

    // Try moving block down
    // Note: we can't use IMoveSystem here because we need to safe call it
    bytes32 applyObjectTypeId = ObjectType.get(IStore(worldAddress), applyEntityId);
    bytes32 applyObjectEntityId = ObjectEntity.get(IStore(worldAddress), applyEntityId);

    GravityMetadata.set(worldAddress, applyObjectEntityId, BlockDirection.None);

    // Check if the agent has health, and if so, apply damage
    uint256 currentHealth = Health.getHealth(worldAddress, applyObjectEntityId);
    if (currentHealth > 0) {
      uint256 newHealth = safeSubtract(currentHealth, GRAVITY_DAMAGE);
      Health.setHealth(worldAddress, applyObjectEntityId, newHealth);

      if (newHealth == 0) {
        IMineSystem(worldAddress).mine(
          bytes32(0), // No acting object entity, since this is the simulator calling it
          applyObjectTypeId,
          positionDataToVoxelCoord(Position.get(IStore(worldAddress), applyEntityId))
        );
        return applyEntityId;
      }
    }

    VoxelCoord memory newCoord = VoxelCoord({ x: applyCoord.x, y: applyCoord.y - 1, z: applyCoord.z });
    (bool moveSuccess, bytes memory moveReturnData) = callWorldMove(
      MoveTrigger.Gravity,
      worldAddress,
      actingObjectEntityId,
      applyObjectEntityId,
      applyObjectTypeId,
      applyCoord,
      newCoord
    );
    if (moveSuccess && moveReturnData.length > 0) {
      // TODO: Should do safe decoding here
      (, applyEntityId) = abi.decode(moveReturnData, (bytes32, bytes32));
    } else {
      // Could not move
      // TODO: Should we do something else here?
    }

    return applyEntityId;
  }

  function supportingBottomBlockExists(
    address worldAddress,
    bytes32 applyEntityId,
    VoxelCoord memory applyCoord
  ) internal returns (bool) {
    // Check if there is mass below the block we are applying gravity to
    uint256 belowMass = 0;
    VoxelCoord memory belowCoord = VoxelCoord({ x: applyCoord.x, y: applyCoord.y - 1, z: applyCoord.z });
    bytes32 belowEntityId = getEntityAtCoord(IStore(worldAddress), belowCoord);
    if (belowEntityId != bytes32(0)) {
      belowMass = Mass.get(worldAddress, ObjectEntity.get(IStore(worldAddress), belowEntityId));
    } else {
      ObjectProperties memory emptyProperties;
      ObjectProperties memory terrainProperties = ITerrainSystem(worldAddress).getTerrainObjectProperties(
        belowCoord,
        emptyProperties
      );
      belowMass = terrainProperties.mass;
    }
    if (belowMass > 0 && applyEntityId != bytes32(0)) {
      GravityMetadata.set(worldAddress, ObjectEntity.get(IStore(worldAddress), applyEntityId), BlockDirection.Down);
    }

    return belowMass > 0;
  }

  function supportingSideBlockExists(
    address worldAddress,
    bytes32 applyEntityId,
    VoxelCoord memory applyCoord
  ) internal returns (bool) {
    (bytes32[] memory neighbourEntities, VoxelCoord[] memory neighbourCoords) = getVonNeumannNeighbourEntities(
      IStore(worldAddress),
      applyCoord
    );
    uint256 applyMass = 0;
    if (applyEntityId != bytes32(0)) {
      applyMass = Mass.get(worldAddress, ObjectEntity.get(IStore(worldAddress), applyEntityId));
    } else {
      ObjectProperties memory emptyProperties;
      ObjectProperties memory terrainProperties = ITerrainSystem(worldAddress).getTerrainObjectProperties(
        applyCoord,
        emptyProperties
      );
      applyMass = terrainProperties.mass;
    }
    for (uint256 i = 0; i < neighbourEntities.length; i++) {
      BlockDirection blockDirection = calculateBlockDirection(applyCoord, neighbourCoords[i]);
      if (
        blockDirection == BlockDirection.Down ||
        blockDirection == BlockDirection.Up ||
        blockDirection == BlockDirection.None
      ) {
        continue;
      }

      uint256 neighbourMass = 0;
      if (neighbourEntities[i] != bytes32(0)) {
        bytes32 neighbourObjectEntityId = ObjectEntity.get(IStore(worldAddress), neighbourEntities[i]);
        neighbourMass = Mass.get(worldAddress, neighbourObjectEntityId);
        BlockDirection neighbourSupportDirection = GravityMetadata.get(worldAddress, neighbourObjectEntityId);
        if (neighbourSupportDirection == getOppositeDirection(blockDirection)) {
          // If the neighbour is being supported by this block, then it can't support this block
          // it needs to have its own support
          continue;
        }
      } else {
        ObjectProperties memory emptyProperties;
        ObjectProperties memory terrainProperties = ITerrainSystem(worldAddress).getTerrainObjectProperties(
          neighbourCoords[i],
          emptyProperties
        );
        neighbourMass = terrainProperties.mass;
      }

      if (neighbourMass >= applyMass) {
        if (applyEntityId != bytes32(0)) {
          GravityMetadata.set(worldAddress, ObjectEntity.get(IStore(worldAddress), applyEntityId), blockDirection);
        }
        return true;
      }
    }

    return false;
  }
}
