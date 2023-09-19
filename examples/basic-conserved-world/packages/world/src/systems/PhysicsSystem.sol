// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { OwnedBy, Position, VoxelType, VoxelTypeProperties, BodyPhysics, BodyPhysicsData } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { min, safeSubtract } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { BuildWorldEventData } from "@tenet-world/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { WorldConfig, WorldConfigTableId } from "@tenet-base-world/src/codegen/tables/WorldConfig.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { console } from "forge-std/console.sol";

uint256 constant MAXIMUM_ENERGY_OUT = 100;

contract PhysicsSystem is System {
  // Go through all the neighbours and equally take from each one, up till MAXIMUM_ENERGY_IN
  // if it runs out, go to the next set of neighbours, another radius away
  function fluxEnergyIn(address caAddress, VoxelEntity memory centerVoxelEntity, uint256 energyToFluxIn) public {
    uint8 radius = 1;
    uint32 scale = centerVoxelEntity.scale;
    while (energyToFluxIn > 0) {
      if (radius > 255) {
        revert("Ran out of neighbours to flux energy from");
      }
      (
        bytes32[] memory neighbourEntities,
        ,
        uint256 numNeighboursWithValues,
        uint256[] memory energyRemaining
      ) = initializeNeighbours(caAddress, centerVoxelEntity, radius, scale);

      if (numNeighboursWithValues == 0) {
        radius += 1;
        continue;
      }

      energyToFluxIn = processRadius(
        scale,
        neighbourEntities,
        energyToFluxIn,
        numNeighboursWithValues,
        energyRemaining
      );

      radius += 1;
    }
  }

  function initializeNeighbours(
    address caAddress,
    VoxelEntity memory centerVoxelEntity,
    uint8 radius,
    uint32 scale
  )
    internal
    returns (
      bytes32[] memory neighbourEntities,
      VoxelCoord[] memory neighbourCoords,
      uint256 numNeighboursWithValues,
      uint256[] memory energyRemaining
    )
  {
    (neighbourEntities, neighbourCoords) = IWorld(_world()).calculateMooreNeighbourEntities(centerVoxelEntity, radius);
    numNeighboursWithValues = 0;

    // Initialize an array to store how much energy can still be taken from each neighbor
    energyRemaining = new uint256[](neighbourEntities.length);

    for (uint256 i = 0; i < neighbourEntities.length; i++) {
      if (uint256(neighbourEntities[i]) == 0) {
        // create the entities that don't exist from the terrain
        (bytes32 terrainVoxelTypeId, BodyPhysicsData memory terrainPhysicsData) = IWorld(_world())
          .getTerrainBodyPhysicsData(caAddress, neighbourCoords[i]);
        if (terrainPhysicsData.energy == 0) {
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

      if (BodyPhysics.getEnergy(scale, neighbourEntities[i]) > 0) {
        energyRemaining[i] = MAXIMUM_ENERGY_OUT;
        numNeighboursWithValues++;
      }
    }
  }

  function processRadius(
    uint32 scale,
    bytes32[] memory neighbourEntities,
    uint256 energyToFluxIn,
    uint256 numNeighboursWithValues,
    uint256[] memory energyRemaining
  ) internal returns (uint256) {
    bool shouldIncreaseRadius = false;
    while (!shouldIncreaseRadius) {
      // Calculate the average amount of energy to give to each neighbor
      // TODO: This should be based on gravity, not just a flat amount
      uint energyPerNeighbor = energyToFluxIn / numNeighboursWithValues;
      if (energyToFluxIn < numNeighboursWithValues) {
        energyPerNeighbor = energyToFluxIn;
      }

      shouldIncreaseRadius = true;
      for (uint i = 0; i < neighbourEntities.length; i++) {
        bytes32 neighborEntity = neighbourEntities[i];
        if (uint256(neighborEntity) == 0) {
          continue;
        }
        uint256 neighbourEnergy = BodyPhysics.getEnergy(scale, neighborEntity);
        if (neighbourEnergy == 0) {
          continue;
        }
        if (energyRemaining[i] == 0) {
          continue;
        }

        uint256 energyToTake = min(min(energyPerNeighbor, energyRemaining[i]), neighbourEnergy);

        // Transfer the energy
        uint256 newNeighbourEnergy = safeSubtract(neighbourEnergy, energyToTake);
        BodyPhysics.setEnergy(scale, neighborEntity, newNeighbourEnergy);

        // Decrease the amount of energy left to dissipate
        energyRemaining[i] = safeSubtract(energyRemaining[i], energyToTake);
        energyToFluxIn = safeSubtract(energyToFluxIn, energyToTake);

        // If we have successfully dissipated all energy, exit the loop
        if (energyToFluxIn == 0) {
          break;
        }

        if (newNeighbourEnergy == 0) {
          numNeighboursWithValues -= 1;
        }

        // If any neighbor still has energy remaining that we can take, don't increase the radius yet.
        if (energyRemaining[i] > 0) {
          shouldIncreaseRadius = false;
        }
      }

      if (numNeighboursWithValues == 0) {
        break;
      }
    }

    return energyToFluxIn;
  }

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
    IWorld(_world()).runCA(caAddress, eventVoxelEntity, bytes4(0));

    BodyPhysics.set(scale, newEntityId, bodyPhysicsData);

    return eventVoxelEntity;
  }
}
