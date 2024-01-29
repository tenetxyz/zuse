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
import { VoxelCoord, ObjectProperties, BlockDirection } from "@tenet-utils/src/Types.sol";
import { getEntityAtCoord, getVoxelCoordStrict, getEntityIdFromObjectEntityId, getVonNeumannNeighbourEntities } from "@tenet-base-world/src/Utils.sol";
import { isZeroCoord, voxelCoordsAreEqual, dot, mulScalar, divScalar, add, sub, calculateBlockDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { abs, absInt32 } from "@tenet-utils/src/MathUtils.sol";
import { WORLD_MOVE_SIG } from "@tenet-base-world/src/Constants.sol";
import { uint256ToInt32, int256ToUint256, safeSubtract } from "@tenet-utils/src/TypeUtils.sol";
import { console } from "forge-std/console.sol";

contract GravityRuleSystem is System {
  function applyGravity(
    address worldAddress,
    VoxelCoord memory centerCoord,
    bytes32 centerObjectEntityId,
    bytes32 actingObjectEntityId
  ) public returns (bytes32) {
    VoxelCoord memory applyCoord;
    console.log("applyGravity");
    console.logBytes32(centerObjectEntityId);
    console.logInt(centerCoord.x);
    console.logInt(centerCoord.y);
    console.logInt(centerCoord.z);

    uint256 currentMass = Mass.get(worldAddress, centerObjectEntityId);
    console.log("currentMass");
    console.logUint(currentMass);
    if (currentMass == 0) {
      // if the center mass is 0, then the block we need to apply gravity to is the one above it
      applyCoord = VoxelCoord({ x: centerCoord.x, y: centerCoord.y + 1, z: centerCoord.z });
    } else {
      // else, the gravity is applied to the center block
      applyCoord = centerCoord;
    }

    bytes32 applyEntityId = getEntityAtCoord(IStore(worldAddress), applyCoord);
    bool makeBlockFall = !supportingBottomBlockExists(worldAddress, applyEntityId, applyCoord) &&
      !supportingSideBlockExists(worldAddress, applyEntityId, applyCoord);

    console.log("makeBlockFall");
    console.logBool(makeBlockFall);
    if (makeBlockFall) {
      // tru moving block down
      // Note: we can't use IMoveSystem here because we need to safe call it
      bytes32 objectTypeId = ObjectType.get(IStore(worldAddress), applyEntityId);
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
        // TODO: Should do safe decoding here
        (, applyEntityId) = abi.decode(moveReturnData, (bytes32, bytes32));
      } else {
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
