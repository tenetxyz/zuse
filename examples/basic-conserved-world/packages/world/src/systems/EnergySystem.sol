// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { OwnedBy, Position, VoxelType, VoxelTypeProperties, BodyPhysics, BodyPhysicsData, BodyPhysicsTableId } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { min, add, sub, safeSubtract, safeAdd, abs, absInt32 } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { BuildWorldEventData } from "@tenet-world/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { WorldConfig, WorldConfigTableId } from "@tenet-base-world/src/codegen/tables/WorldConfig.sol";
import { getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { console } from "forge-std/console.sol";

uint256 constant MAXIMUM_ENERGY_OUT = 100;
uint256 constant MAXIMUM_ENERGY_IN = 100;

contract EnergySystem is System {
  function fluxEnergy(
    bool isFluxIn,
    address caAddress,
    VoxelEntity memory centerVoxelEntity,
    uint256 energyToFlux
  ) public {
    uint8 radius = 1;
    uint32 scale = centerVoxelEntity.scale;
    while (energyToFlux > 0) {
      if (radius > 255) {
        revert("Ran out of neighbours to flux energy from");
      }
      (
        bytes32[] memory neighbourEntities,
        ,
        uint256 numNeighboursToInclude,
        uint256[] memory neighbourEnergyDelta
      ) = initializeNeighbours(isFluxIn, caAddress, centerVoxelEntity, radius, scale);

      if (numNeighboursToInclude == 0) {
        radius += 1;
        continue;
      }

      energyToFlux = processRadius(
        isFluxIn,
        scale,
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
    address caAddress,
    VoxelEntity memory centerVoxelEntity,
    uint8 radius,
    uint32 scale
  )
    internal
    returns (
      bytes32[] memory neighbourEntities,
      VoxelCoord[] memory neighbourCoords,
      uint256 numNeighboursToInclude,
      uint256[] memory neighbourEnergyDelta
    )
  {
    (neighbourEntities, neighbourCoords) = IWorld(_world()).calculateMooreNeighbourEntities(centerVoxelEntity, radius);
    numNeighboursToInclude = 0;

    // Initialize an array to store how much energy can still be taken/given from/to each neighbor
    neighbourEnergyDelta = new uint256[](neighbourEntities.length);

    for (uint256 i = 0; i < neighbourEntities.length; i++) {
      if (uint256(neighbourEntities[i]) == 0) {
        // create the entities that don't exist from the terrain
        (bytes32 terrainVoxelTypeId, BodyPhysicsData memory terrainPhysicsData) = IWorld(_world())
          .getTerrainBodyPhysicsData(caAddress, neighbourCoords[i]);
        if (isFluxIn && terrainPhysicsData.energy == 0) {
          // if we are taking energy from the terrain, we can't take from terrain that has no energy
          continue;
        }
        VoxelEntity memory newTerrainEntity = spawnBody(
          terrainVoxelTypeId,
          neighbourCoords[i],
          bytes4(0),
          terrainPhysicsData
        );
        neighbourEntities[i] = newTerrainEntity.entityId;
      }

      if (isFluxIn) {
        if (BodyPhysics.getEnergy(scale, neighbourEntities[i]) > 0) {
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
    uint32 scale,
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
      console.log("energyPerNeighbor");
      console.logUint(energyPerNeighbor);
      console.logUint(numNeighboursToInclude);
      if (energyToFlux < numNeighboursToInclude) {
        energyPerNeighbor = energyToFlux;
      }

      shouldIncreaseRadius = true;
      for (uint i = 0; i < neighbourEntities.length; i++) {
        bytes32 neighborEntity = neighbourEntities[i];
        if (uint256(neighborEntity) == 0) {
          continue;
        }
        uint256 neighbourEnergy = BodyPhysics.getEnergy(scale, neighborEntity);
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
        BodyPhysics.setEnergy(scale, neighborEntity, newNeighbourEnergy);

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

  // TODO: This should be in a separate contract
  function spawnBody(
    bytes32 voxelTypeId,
    VoxelCoord memory coord,
    bytes4 mindSelector,
    BodyPhysicsData memory bodyPhysicsData
  ) public returns (VoxelEntity memory) {
    VoxelTypeRegistryData memory voxelTypeData = VoxelTypeRegistry.get(IStore(REGISTRY_ADDRESS), voxelTypeId);
    address caAddress = WorldConfig.get(voxelTypeId);

    // Create new body entity
    uint32 scale = voxelTypeData.scale;
    bytes32 newEntityId = getUniqueEntity();
    VoxelEntity memory eventVoxelEntity = VoxelEntity({ scale: scale, entityId: newEntityId });
    Position.set(scale, newEntityId, coord.x, coord.y, coord.z);

    // Update layers
    IWorld(_world()).enterCA(caAddress, eventVoxelEntity, voxelTypeId, mindSelector, coord);
    CAVoxelTypeData memory entityCAVoxelType = CAVoxelType.get(IStore(caAddress), _world(), newEntityId);
    VoxelType.set(scale, newEntityId, entityCAVoxelType.voxelTypeId, entityCAVoxelType.voxelVariantId);
    // TODO: Should we run this?
    // IWorld(_world()).runCA(caAddress, eventVoxelEntity, bytes4(0));

    BodyPhysics.set(scale, newEntityId, bodyPhysicsData);

    return eventVoxelEntity;
  }
}
