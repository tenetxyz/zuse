// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { ITerrainSystem } from "@tenet-base-world/src/codegen/world/ITerrainSystem.sol";
import { IBuildSystem } from "@tenet-base-world/src/codegen/world/IBuildSystem.sol";

import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy, EnergyTableId } from "@tenet-simulator/src/codegen/tables/Energy.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { add, sub } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { min } from "@tenet-utils/src/MathUtils.sol";
import { safeSubtract, safeAdd } from "@tenet-utils/src/TypeUtils.sol";
import { getMooreNeighbourEntities, getEntityIdFromObjectEntityId } from "@tenet-base-world/src/Utils.sol";

uint256 constant MAXIMUM_ENERGY_OUT = 100;
uint256 constant MAXIMUM_ENERGY_IN = 2500;

uint256 constant MAX_FLUX_RADIUS = 255;

contract FluxEnergySystem is System {
  function fluxEnergy(bool isFluxIn, address worldAddress, bytes32 centerObjectEntityId, uint256 energyToFlux) public {
    require(
      hasKey(EnergyTableId, Energy.encodeKeyTuple(worldAddress, centerObjectEntityId)),
      "Entity with energy does not exist"
    );
    uint8 radius = 1;
    while (energyToFlux > 0) {
      if (radius > MAX_FLUX_RADIUS) {
        revert("FluxEnergySystem: Reached maximum flux radius");
      }
      (
        bytes32[] memory neighbourObjectEntities,
        ,
        uint256 numNeighboursToInclude,
        uint256[] memory neighbourEnergyDelta
      ) = initializeNeighbours(isFluxIn, worldAddress, centerObjectEntityId, radius);

      if (numNeighboursToInclude == 0) {
        radius += 1;
        continue;
      }

      energyToFlux = processRadius(
        isFluxIn,
        worldAddress,
        neighbourObjectEntities,
        energyToFlux,
        numNeighboursToInclude,
        neighbourEnergyDelta
      );
      radius += 1;
    }
  }

  function initializeNeighbours(
    bool isFluxIn,
    address worldAddress,
    bytes32 centerObjectEntityId,
    uint8 radius
  )
    internal
    returns (
      bytes32[] memory neighbourObjectEntities,
      VoxelCoord[] memory neighbourCoords,
      uint256 numNeighboursToInclude,
      uint256[] memory neighbourEnergyDelta
    )
  {
    bytes32[] memory neighbourEntities;
    (neighbourEntities, neighbourCoords) = getMooreNeighbourEntities(
      IStore(worldAddress),
      getEntityIdFromObjectEntityId(IStore(worldAddress), centerObjectEntityId),
      radius
    );
    numNeighboursToInclude = 0;

    // Initialize an array to store how much energy can still be taken/given from/to each neighbor
    neighbourEnergyDelta = new uint256[](neighbourEntities.length);

    ObjectProperties memory emptyProperties;

    for (uint256 i = 0; i < neighbourEntities.length; i++) {
      if (uint256(neighbourEntities[i]) == 0) {
        ObjectProperties memory terrainProperties = ITerrainSystem(worldAddress).getTerrainObjectProperties(
          neighbourCoords[i],
          emptyProperties
        );
        if (isFluxIn) {
          if (terrainProperties.energy == 0) {
            // if we are taking energy from the terrain, we can't take from terrain that has no energy
            continue;
          }
        } else {
          // if we are giving energy to the terrain, we can only give to terrain that has mass
          // ie air doesn't have mass, and so we can't give energy to it
          if (terrainProperties.mass == 0) {
            continue;
          }
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

      if (isFluxIn) {
        if (Energy.get(worldAddress, neighbourObjectEntities[i]) > 0) {
          // we only flux in to neighbours that have energy
          neighbourEnergyDelta[i] = MAXIMUM_ENERGY_OUT;
          numNeighboursToInclude++;
        }
      } else {
        if (Mass.get(worldAddress, neighbourObjectEntities[i]) > 0) {
          // we only flux out to neighbours that have mass
          neighbourEnergyDelta[i] = MAXIMUM_ENERGY_IN;
          numNeighboursToInclude++;
        }
      }
    }
  }

  function processRadius(
    bool isFluxIn,
    address worldAddress,
    bytes32[] memory neighbourObjectEntities,
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
      for (uint i = 0; i < neighbourObjectEntities.length; i++) {
        bytes32 neighborObjectEntityId = neighbourObjectEntities[i];
        if (uint256(neighborObjectEntityId) == 0) {
          continue;
        }
        uint256 neighbourEnergy = Energy.get(worldAddress, neighborObjectEntityId);
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
        Energy.set(worldAddress, neighborObjectEntityId, newNeighbourEnergy);

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
