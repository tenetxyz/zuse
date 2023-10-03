// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { min, add, sub, safeSubtract, safeAdd, abs, absInt32 } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { console } from "forge-std/console.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity, getNeighbourEntities, createTerrainEntity } from "@tenet-simulator/src/Utils.sol";

uint256 constant MAXIMUM_ENERGY_OUT = 100;
uint256 constant MAXIMUM_ENERGY_IN = 100;

contract EnergyHelperSystem is System {
  // Users can call this
  function fluxEnergy(bool isFluxIn, address callerAddress, bytes32 entityId, uint256 energyToFlux) public {
    uint8 radius = 1;
    while (energyToFlux > 0) {
      if (radius > 255) {
        revert("Ran out of neighbours to flux energy from");
      }
      (
        bytes32[] memory neighbourEntities,
        ,
        uint256 numNeighboursToInclude,
        uint256[] memory neighbourEnergyDelta
      ) = initializeNeighbours(isFluxIn, callerAddress, entityId, radius);

      if (numNeighboursToInclude == 0) {
        radius += 1;
        continue;
      }

      energyToFlux = processRadius(
        isFluxIn,
        callerAddress,
        neighbourEntities,
        energyToFlux,
        numNeighboursToInclude,
        neighbourEnergyDelta
      );
      radius += 1;
    }
  }

  function initializeNeighbours(
    bool isFluxIn,
    address callerAddress,
    bytes32 entityId,
    uint8 radius
  )
    internal
    returns (
      bytes32[] memory neighbourEntities,
      VoxelCoord[] memory neighbourCoords,
      uint256 numNeighboursToInclude,
      uint256[] memory neighbourEnergyDelta
    )
  {
    (neighbourEntities, neighbourCoords) = getNeighbourEntities(callerAddress, entityId, radius);
    numNeighboursToInclude = 0;

    // Initialize an array to store how much energy can still be taken/given from/to each neighbor
    neighbourEnergyDelta = new uint256[](neighbourEntities.length);

    for (uint256 i = 0; i < neighbourEntities.length; i++) {
      if (uint256(neighbourEntities[i]) == 0) {
        if (isFluxIn && getTerrainEnergy(callerAddress, neighbourCoords[i]) == 0) {
          // if we are taking energy from the terrain, we can't take from terrain that has no energy
          continue;
        }
        // create the entities that don't exist from the terrain
        VoxelEntity memory newTerrainEntity = createTerrainEntity(callerAddress, neighbourCoords[i]);
        neighbourEntities[i] = newTerrainEntity.entityId;
      }

      if (isFluxIn) {
        if (Energy.get(callerAddress, neighbourEntities[i]) > 0) {
          // we only flux in to neighbours that have energy
          neighbourEnergyDelta[i] = MAXIMUM_ENERGY_OUT;
          numNeighboursToInclude++;
        }
      } else {
        // we can flux out to all the neighbours
        neighbourEnergyDelta[i] = MAXIMUM_ENERGY_IN;
        numNeighboursToInclude++;
      }
    }
  }

  function processRadius(
    bool isFluxIn,
    address callerAddress,
    bytes32[] memory neighbourEntities,
    uint256 energyToFlux,
    uint256 numNeighboursToInclude,
    uint256[] memory neighbourEnergyDelta
  ) internal returns (uint256) {
    bool shouldIncreaseRadius = false;
    while (!shouldIncreaseRadius) {
      // Calculate the average amount of energy to give/take to/from each neighbor
      // TODO: This should be based on gravity, not just a flat amount
      uint energyPerNeighbor = energyToFlux / numNeighboursToInclude;
      if (energyToFlux < numNeighboursToInclude) {
        energyPerNeighbor = energyToFlux;
      }

      shouldIncreaseRadius = true;
      for (uint i = 0; i < neighbourEntities.length; i++) {
        bytes32 neighborEntity = neighbourEntities[i];
        if (uint256(neighborEntity) == 0) {
          continue;
        }
        uint256 neighbourEnergy = Energy.get(callerAddress, neighborEntity);
        if (isFluxIn && neighbourEnergy == 0) {
          continue;
        }
        if (neighbourEnergyDelta[i] == 0) {
          continue;
        }

        uint256 energyToTransfer = min(energyPerNeighbor, neighbourEnergyDelta[i]);
        if (isFluxIn) {
          // We can't take more energy than the neighbor has
          energyToTransfer = min(energyToTransfer, neighbourEnergy);
        }

        // Transfer the energy
        uint256 newNeighbourEnergy = isFluxIn
          ? safeSubtract(neighbourEnergy, energyToTransfer)
          : safeAdd(neighbourEnergy, energyToTransfer);
        Energy.set(callerAddress, neighborEntity, newNeighbourEnergy);

        // Decrease the amount of energy left to flux
        neighbourEnergyDelta[i] = safeSubtract(neighbourEnergyDelta[i], energyToTransfer);
        energyToFlux = safeSubtract(energyToFlux, energyToTransfer);

        // If we have successfully fluxed all energy, exit the loop
        if (energyToFlux == 0) {
          break;
        }

        if (newNeighbourEnergy == 0 || neighbourEnergyDelta[i] == 0) {
          numNeighboursToInclude -= 1;
        }

        // If any neighbor still has a delta of energy that we can flux, don't increase the radius yet.
        if (neighbourEnergyDelta[i] > 0) {
          shouldIncreaseRadius = false;
        }
      }

      if (numNeighboursToInclude == 0) {
        break;
      }
    }

    return energyToFlux;
  }
}
