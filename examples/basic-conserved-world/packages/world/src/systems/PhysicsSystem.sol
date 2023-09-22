// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { OwnedBy, Position, VoxelType, VoxelTypeProperties, BodyPhysics, BodyPhysicsData, BodyPhysicsTableId } from "@tenet-world/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { uint256ToInt32, dot, mulScalar, divScalar, min, add, sub, safeSubtract, safeAdd, abs, absInt32 } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { BuildWorldEventData } from "@tenet-world/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { CAVoxelType, CAVoxelTypeData } from "@tenet-base-ca/src/codegen/tables/CAVoxelType.sol";
import { WorldConfig, WorldConfigTableId } from "@tenet-base-world/src/codegen/tables/WorldConfig.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { console } from "forge-std/console.sol";
import { getVelocity } from "@tenet-world/src/Utils.sol";

uint256 constant MAXIMUM_ENERGY_OUT = 100;
uint256 constant MAXIMUM_ENERGY_IN = 100;

contract PhysicsSystem is System {
  function onCollision(address caAddress, VoxelCoord memory centerCoord, VoxelEntity memory centerVoxelEntity) public {
    (bytes32[] memory neighbourEntities, VoxelCoord[] memory neighbourCoords) = IWorld(_world())
      .calculateNeighbourEntities(centerVoxelEntity);
    VoxelCoord memory primaryVelocity = getVelocity(centerVoxelEntity);

    bytes32[] memory collidingEntities = new bytes32[](neighbourEntities.length);

    // We first compute the dot product to figure out for which coords, do we need to run the collison formula
    for (uint8 i = 0; i < neighbourCoords.length; i++) {
      VoxelCoord memory relativePosition = sub(neighbourCoords[i], centerCoord);
      int dotProduct = dot(primaryVelocity, relativePosition);
      if (dotProduct > 0) {
        // this means the primary voxel is moving towards the neighbour
        if (uint256(neighbourEntities[i]) == 0) {
          // create the entities that don't exist from the terrain
          (bytes32 terrainVoxelTypeId, BodyPhysicsData memory terrainPhysicsData) = IWorld(_world())
            .getTerrainBodyPhysicsData(caAddress, neighbourCoords[i]);
          VoxelEntity memory newTerrainEntity = spawnBody(
            terrainVoxelTypeId,
            neighbourCoords[i],
            bytes4(0),
            terrainPhysicsData
          );
          neighbourEntities[i] = newTerrainEntity.entityId;
        }
        collidingEntities[i] = neighbourEntities[i];
      } else {
        collidingEntities[i] = 0;
      }
    }

    int32 mass_primary = uint256ToInt32(BodyPhysics.getMass(centerVoxelEntity.scale, centerVoxelEntity.entityId));

    // Now we run the collision formula for each of the colliding entities
    VoxelCoord memory total_impulse = VoxelCoord({ x: 0, y: 0, z: 0 });
    for (uint8 i = 0; i < collidingEntities.length; i++) {
      if (uint256(collidingEntities[i]) == 0) {
        continue;
      }
      // Calculate the impulse of this neighbour
      VoxelCoord memory relativeVelocity = sub(
        getVelocity(VoxelEntity({ scale: centerVoxelEntity.scale, entityId: collidingEntities[i] })),
        primaryVelocity
      );
      int32 mass_neighbour = uint256ToInt32(BodyPhysics.getMass(centerVoxelEntity.scale, collidingEntities[i]));
      VoxelCoord memory impulse = mulScalar(relativeVelocity, (2 * mass_neighbour) / (mass_primary + mass_neighbour));
      // Add to total impulse
      total_impulse = add(total_impulse, impulse);
    }

    VoxelCoord memory delta_velocity = divScalar(total_impulse, mass_primary);
    VoxelCoord memory new_primary_velocity = add(primaryVelocity, delta_velocity);
    BodyPhysics.setVelocity(centerVoxelEntity.scale, centerVoxelEntity.entityId, abi.encode(new_primary_velocity));
  }

  function updateVelocity(
    address caAddress,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    VoxelEntity memory oldEntity,
    VoxelEntity memory newEntity
  ) public {
    BodyPhysicsData memory oldBodyPhysicsData = BodyPhysics.get(oldEntity.scale, oldEntity.entityId);
    uint256 bodyMass = oldBodyPhysicsData.mass;
    (VoxelCoord memory newVelocity, uint256 energyRequired) = calculateNewVelocity(
      oldCoord,
      newCoord,
      oldEntity,
      bodyMass
    );
    require(energyRequired <= oldBodyPhysicsData.energy, "Not enough energy to move.");

    if (!hasKey(BodyPhysicsTableId, BodyPhysics.encodeKeyTuple(newEntity.scale, newEntity.entityId))) {
      (, BodyPhysicsData memory terrainPhysicsData) = IWorld(_world()).getTerrainBodyPhysicsData(caAddress, newCoord);
      BodyPhysics.set(newEntity.scale, newEntity.entityId, terrainPhysicsData);
    }
    uint256 energyInNewBlock = BodyPhysics.getEnergy(newEntity.scale, newEntity.entityId);

    // Reset the old entity's mass, energy and velocity
    BodyPhysics.setMass(oldEntity.scale, oldEntity.entityId, 0);
    BodyPhysics.setEnergy(oldEntity.scale, oldEntity.entityId, 0);
    BodyPhysics.setVelocity(oldEntity.scale, oldEntity.entityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));

    fluxEnergy(false, caAddress, newEntity, energyRequired + energyInNewBlock);

    // Update the new entity's energy and velocity
    oldBodyPhysicsData.energy -= energyRequired;
    oldBodyPhysicsData.velocity = abi.encode(newVelocity);
    BodyPhysics.set(newEntity.scale, newEntity.entityId, oldBodyPhysicsData);
  }

  function calculateNewVelocity(
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    VoxelEntity memory oldEntity,
    uint256 bodyMass
  ) internal view returns (VoxelCoord memory, uint256) {
    VoxelCoord memory currentVelocity = getVelocity(oldEntity);
    VoxelCoord memory newVelocity = VoxelCoord({
      x: currentVelocity.x + (newCoord.x - oldCoord.x),
      y: currentVelocity.y + (newCoord.y - oldCoord.y),
      z: currentVelocity.z + (newCoord.z - oldCoord.z)
    });
    VoxelCoord memory velocityDelta = VoxelCoord({
      x: absInt32(newVelocity.x) - absInt32(currentVelocity.x),
      y: absInt32(newVelocity.y) - absInt32(currentVelocity.y),
      z: absInt32(newVelocity.z) - absInt32(currentVelocity.z)
    });

    uint256 energyRequiredX = calculateEnergyRequired(currentVelocity.x, newVelocity.x, velocityDelta.x, bodyMass);
    uint256 energyRequiredY = calculateEnergyRequired(currentVelocity.y, newVelocity.y, velocityDelta.y, bodyMass);
    uint256 energyRequiredZ = calculateEnergyRequired(currentVelocity.z, newVelocity.z, velocityDelta.z, bodyMass);
    uint256 energyRequired = energyRequiredX + energyRequiredY + energyRequiredZ;
    return (newVelocity, energyRequired);
  }

  // Note: We assume the magnitude of the delta is always 1,
  // ie the body is moving 1 voxel at a time
  function calculateEnergyRequired(
    int32 currentVelocity,
    int32 newVelocity,
    int32 velocityDelta,
    uint256 bodyMass
  ) internal pure returns (uint256) {
    uint256 energyRequired = 0;
    if (velocityDelta != 0) {
      energyRequired = bodyMass;
      if (newVelocity != 0) {
        energyRequired = velocityDelta > 0
          ? bodyMass / uint(abs(int(newVelocity))) // if we're going in the same direction, then it costs less
          : bodyMass * uint(abs(int(newVelocity))); // if we're going in the opposite direction, then it costs more
      }
    }
    return energyRequired;
  }

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
