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
  // Mass has no constraints since voxel types can't modify it right now

  // Behaviours
  function changeMassBehaviour(bytes32 entityId, VoxelCoord memory coord, uint256 newMass) public {
    address callerAddress = _msgSender();
    bool entityExists = hasKey(MassTableId, Mass.encodeKeyTuple(callerAddress, entityId));
    if (newMass > 0) {
      // this is a build event
      if (entityExists) {
        require(Mass.get(callerAddress, entityId) == 0, "Cannot build on top of an entity with mass");
      } else {
        uint256 terrainMass = getTerrainMass(callerAddress, coord);
        require(terrainMass == 0, "Cannot build on top of terrain with mass");
      }

      // Calculate how much energy this operation requires
      uint256 energyRequired = newMass * 10;
      IWorld(_world()).fluxEnergy(true, callerAddress, entityId, energyRequired);
      if (!entityExists) {
        Mass.set(callerAddress, entityId, newMass);
        Energy.set(callerAddress, entityId, 0);
        Velocity.set(callerAddress, entityId, block.number, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));
      } else {
        Mass.set(callerAddress, entityId, newMass);
      }
    } else {
      // this is a mine event
      uint256 massToMine;
      if (entityExists) {
        require(isZeroCoord(getVelocity(callerAddress, entityId)), "Cannot mine an entity with velocity");
        massToMine = Mass.get(callerAddress, entityId);
        require(massToMine > 0, "Cannot mine an entity with no mass");
      } else {
        VoxelCoord memory terrainVelocity = getTerrainVelocity(callerAddress, coord);
        uint256 terrainMass = getTerrainMass(callerAddress, coord);
        massToMine = terrainMass;
        require(isZeroCoord(terrainVelocity), "Cannot mine terrain with velocity");
        require(terrainMass > 0, "Cannot mine terrain with no mass");

        Mass.set(callerAddress, entityId, terrainMass);
        Energy.set(callerAddress, entityId, getTerrainEnergy(callerAddress, coord));
        Velocity.set(callerAddress, entityId, block.number, abi.encode(terrainVelocity));
      }

      // Calculate how much energy this operation requires
      uint256 energyRequired = massToMine * 10;
      IWorld(_world()).fluxEnergy(false, callerAddress, entityId, energyRequired);
      Mass.set(callerAddress, entityId, 0);
    }
  }
}
