// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { OwnedBy, Position, VoxelType, VoxelTypeProperties, BodyPhysics, BodyPhysicsData } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { min } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { BuildWorldEventData } from "@tenet-world/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { WorldConfig, WorldConfigTableId } from "@tenet-base-world/src/codegen/tables/WorldConfig.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

uint256 constant MAXIMUM_ENERGY_OUT = 100;

contract PhysicsSystem is System {
  function fluxEnergyIn(address caAddress, VoxelEntity memory centerVoxelEntity, uint256 energyToFluxIn) public {
    // Go through all the neighbours and equally take from each one, up till MAXIMUM_ENERGY_IN
    // if it runs out, go to the next set of neighbours, another radius away
    uint8 radius = 1;
    uint32 scale = centerVoxelEntity.scale;
    while (energyToFluxIn > 0) {
      if (radius > 255) {
        revert("Ran out of neighbours to dissipate energy into");
      }
      (bytes32[] memory useNeighbourEntities, VoxelCoord[] memory neighbourCoords) = IWorld(_world())
        .calculateMooreNeighbourEntities(centerVoxelEntity, radius);
      uint256 numNeighboursWithValues = 0;

      for (uint256 i = 0; i < useNeighbourEntities.length; i++) {
        if (useNeighbourEntities[i] == bytes32(0)) {
          // create the entities that don't exist from the terrain
          (bytes32 terrainVoxelTypeId, BodyPhysicsData memory terrainPhysicsData) = IWorld(_world())
            .getTerrainBodyPhysicsData(caAddress, neighbourCoords[i]);
          if (terrainPhysicsData.mass == 0) {
            continue;
          }
          VoxelEntity memory newTerrainEntity = spawnBody(
            terrainVoxelTypeId,
            neighbourCoords[i],
            bytes4(0),
            terrainPhysicsData
          );
          useNeighbourEntities[i] = newTerrainEntity.entityId;
        }

        if (BodyPhysics.getEnergy(scale, useNeighbourEntities[i]) > 0) {
          numNeighboursWithValues++;
        }
      }

      if (numNeighboursWithValues == 0) {
        radius += 1;
        continue;
      }

      // Calculate the average amount of energy to give to each neighbor
      // TODO: This should be based on gravity, not just a flat amount
      uint energyPerNeighbor = energyToFluxIn / numNeighboursWithValues;

      for (uint i = 0; i < useNeighbourEntities.length; i++) {
        bytes32 neighborEntity = useNeighbourEntities[i];
        if (neighborEntity == bytes32(0)) {
          continue;
        }
        uint256 neighbourEnergy = BodyPhysics.getEnergy(scale, neighborEntity);
        if (neighbourEnergy == 0) {
          continue;
        }

        uint256 energyToTake = min(energyPerNeighbor, MAXIMUM_ENERGY_OUT);
        if (neighbourEnergy < energyToTake) {
          energyToTake = neighbourEnergy;
        }

        // Transfer the energy
        BodyPhysics.setEnergy(scale, neighborEntity, neighbourEnergy - energyToTake);

        // Decrease the amount of energy left to dissipate
        if (energyToTake > energyToFluxIn) {
          energyToFluxIn = 0;
        } else {
          energyToFluxIn -= energyToTake;
        }

        // If we have successfully dissipated all energy, exit the loop
        if (energyToFluxIn == 0) {
          break;
        }
      }

      // If we've gone through all neighbors and still have energy to dissipate, increase the radius
      if (energyToFluxIn > 0) {
        radius += 1;
      }
    }
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
