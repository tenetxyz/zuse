// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { console } from "forge-std/console.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";

contract MassSystem is System {
  // Constraints

  // Behaviours
  function massChange(VoxelEntity memory entity, VoxelCoord memory coord, uint256 newMass) public {
    address callerAddress = _msgSender();
    bool entityExists = hasKey(MassTableId, Mass.encodeKeyTuple(callerAddress, entity.scale, entity.entityId));
    if (newMass > 0) {
      // this is a build event
      bool isBuild = false;
      if (entityExists) {
        uint256 currentMass = Mass.get(callerAddress, entity.scale, entity.entityId);
        if (currentMass == 0) {
          isBuild = true;
        } else {
          // Note: we only allow mass to decrease
          require(currentMass > newMass, "Not enough mass to flux");
        }
      } else {
        uint256 terrainMass = getTerrainMass(callerAddress, entity.scale, coord);
        require(terrainMass == 0, "Cannot build on top of terrain with mass");
        isBuild = true;
      }

      // Calculate how much energy this operation requires
      uint256 energyRequired = newMass * 10;
      IWorld(_world()).fluxEnergy(isBuild, callerAddress, entity, energyRequired);
      if (!entityExists) {
        Mass.set(callerAddress, entity.scale, entity.entityId, newMass);
        Energy.set(callerAddress, entity.scale, entity.entityId, 0);
        Velocity.set(
          callerAddress,
          entity.scale,
          entity.entityId,
          block.number,
          abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 }))
        );
      } else {
        Mass.set(callerAddress, entity.scale, entity.entityId, newMass);
      }
    } else {
      // this is a mine event
      uint256 massToMine;
      if (entityExists) {
        require(isZeroCoord(getVelocity(callerAddress, entity)), "Cannot mine an entity with velocity");
        massToMine = Mass.get(callerAddress, entity.scale, entity.entityId);
        require(massToMine > 0, "Cannot mine an entity with no mass");
      } else {
        VoxelCoord memory terrainVelocity = getTerrainVelocity(callerAddress, entity.scale, coord);
        uint256 terrainMass = getTerrainMass(callerAddress, entity.scale, coord);
        massToMine = terrainMass;
        require(isZeroCoord(terrainVelocity), "Cannot mine terrain with velocity");
        require(terrainMass > 0, "Cannot mine terrain with no mass");

        Mass.set(callerAddress, entity.scale, entity.entityId, terrainMass);
        Energy.set(callerAddress, entity.scale, entity.entityId, getTerrainEnergy(callerAddress, entity.scale, coord));
        Velocity.set(callerAddress, entity.scale, entity.entityId, block.number, abi.encode(terrainVelocity));
      }

      // Calculate how much energy this operation requires
      uint256 energyRequired = massToMine * 10;
      IWorld(_world()).fluxEnergy(false, callerAddress, entity, energyRequired);
      Mass.set(callerAddress, entity.scale, entity.entityId, 0);
    }
  }
}
