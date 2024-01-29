// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Health, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Velocity, VelocityData, VelocityTableId } from "@tenet-simulator/src/codegen/tables/Velocity.sol";

import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { ObjectType } from "@tenet-base-world/src/codegen/tables/ObjectType.sol";
import { ITerrainSystem } from "@tenet-base-world/src/codegen/world/ITerrainSystem.sol";
import { IBuildSystem } from "@tenet-base-world/src/codegen/world/IBuildSystem.sol";
import { IMoveSystem } from "@tenet-base-world/src/codegen/world/IMoveSystem.sol";

import { getVelocity } from "@tenet-simulator/src/Utils.sol";
import { VoxelCoord, ObjectProperties, BlockDirection } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getVoxelCoordStrict, getEntityIdFromObjectEntityId, getVonNeumannNeighbourEntities } from "@tenet-base-world/src/Utils.sol";
import { isZeroCoord, voxelCoordsAreEqual, dot, mulScalar, divScalar, add, sub, calculateBlockDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { abs, absInt32 } from "@tenet-utils/src/MathUtils.sol";
import { WORLD_MOVE_SIG } from "@tenet-base-world/src/Constants.sol";
import { uint256ToInt32, int256ToUint256, safeSubtract } from "@tenet-utils/src/TypeUtils.sol";
import { GRAVITY_DAMAGE } from "@tenet-simulator/src/Constants.sol";
import { console } from "forge-std/console.sol";

contract GravityRuleSystem is System {
  function applyGravity(
    address worldAddress,
    VoxelCoord memory eventCoord,
    bytes32 eventObjectEntityId,
    bytes32 actingObjectEntityId
  ) public returns (bytes32) {
    console.log("applyGravity");
    console.logBytes32(eventObjectEntityId);
    console.logInt(eventCoord.x);
    console.logInt(eventCoord.y);
    console.logInt(eventCoord.z);

    uint256 currentMass = Mass.get(worldAddress, eventObjectEntityId);
    console.log("currentMass");
    console.logUint(currentMass);
    bytes32 eventEntityId = getEntityAtCoord(IStore(worldAddress), eventCoord);
    if (currentMass == 0) {
      (bytes32[] memory neighbourEntities, VoxelCoord[] memory neighbourCoords) = getVonNeumannNeighbourEntities(
        IStore(worldAddress),
        eventEntityId
      );
      for (uint256 i = 0; i < neighbourEntities.length; i++) {
        if (neighbourEntities[i] == bytes32(0)) {
          continue;
        }
        BlockDirection blockDirection = calculateBlockDirection(eventCoord, neighbourCoords[i]);
        if (blockDirection == BlockDirection.Down || blockDirection == BlockDirection.None) {
          continue;
        }
        runGravity(worldAddress, neighbourCoords[i], neighbourEntities[i], actingObjectEntityId);
      }
      // if the center mass is 0, then we need to apply gravity to all the blocks around it
      return eventEntityId;
    } else {
      // else, the gravity is applied to the center block
      return runGravity(worldAddress, eventCoord, eventEntityId, actingObjectEntityId);
    }
  }

  function runGravity(
    address worldAddress,
    VoxelCoord memory applyCoord,
    bytes32 applyEntityId,
    bytes32 actingObjectEntityId
  ) public returns (bytes32) {
    bool makeBlockFall = !supportingBottomBlockExists(worldAddress, applyEntityId, applyCoord) &&
      !supportingSideBlockExists(worldAddress, applyEntityId, applyCoord);

    console.log("makeBlockFall");
    console.logBool(makeBlockFall);
    if (makeBlockFall) {
      // tru moving block down
      // Note: we can't use IMoveSystem here because we need to safe call it
      bytes32 objectTypeId = ObjectType.get(IStore(worldAddress), applyEntityId);
      console.log("calling");
      console.logInt(applyCoord.x);
      console.logInt(applyCoord.y);
      console.logInt(applyCoord.z);
      (bool moveSuccess, bytes memory moveReturnData) = worldAddress.call(
        abi.encodeWithSignature(
          WORLD_MOVE_SIG,
          actingObjectEntityId,
          objectTypeId,
          applyCoord,
          VoxelCoord({ x: applyCoord.x, y: applyCoord.y - 1, z: applyCoord.z })
        )
      );
      if (moveSuccess && moveReturnData.length > 0) {
        // Check if the agent has health, and if so, apply damage
        uint256 currentHealth = Health.getHealth(worldAddress, actingObjectEntityId);
        if (currentHealth > 0) {
          uint256 newHealth = safeSubtract(currentHealth, GRAVITY_DAMAGE);
          Health.setHealth(worldAddress, actingObjectEntityId, newHealth);
        }

        // TODO: Should do safe decoding here
        console.log("move success");
        console.logInt(applyCoord.x);
        console.logInt(applyCoord.y);
        console.logInt(applyCoord.z);
        (, applyEntityId) = abi.decode(moveReturnData, (bytes32, bytes32));
      } else {
        console.log("move failed");
        console.logInt(applyCoord.x);
        console.logInt(applyCoord.y);
        console.logInt(applyCoord.z);
        // Could not move, so we break out of the loop
        // TODO: Should we do something else here?
      }
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
    console.log("belowMass");
    console.logUint(belowMass);
    return belowMass > 0;
  }

  function supportingSideBlockExists(
    address worldAddress,
    bytes32 applyEntityId,
    VoxelCoord memory applyCoord
  ) internal view returns (bool) {
    (bytes32[] memory neighbourEntities, VoxelCoord[] memory neighbourCoords) = getVonNeumannNeighbourEntities(
      IStore(worldAddress),
      applyEntityId
    );
    uint256 applyMass = Mass.get(worldAddress, ObjectEntity.get(IStore(worldAddress), applyEntityId));
    for (uint256 i = 0; i < neighbourEntities.length; i++) {
      if (neighbourEntities[i] == bytes32(0)) {
        continue;
      }
      BlockDirection blockDirection = calculateBlockDirection(applyCoord, neighbourCoords[i]);
      if (
        blockDirection == BlockDirection.Down ||
        blockDirection == BlockDirection.Up ||
        blockDirection == BlockDirection.None
      ) {
        continue;
      }

      uint256 neighbourMass = Mass.get(worldAddress, ObjectEntity.get(IStore(worldAddress), neighbourEntities[i]));
      console.log("neighbourMass");
      console.logUint(neighbourMass);
      if (neighbourMass >= applyMass) {
        return true;
      }
    }

    return false;
  }
}
