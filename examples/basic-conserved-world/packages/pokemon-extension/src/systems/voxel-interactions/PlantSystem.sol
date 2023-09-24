// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { SingleVoxelInteraction } from "@tenet-base-ca/src/prototypes/SingleVoxelInteraction.sol";
import { BlockDirection, BodyPhysicsData, CAEventData, CAEventType, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { EnergySource } from "@tenet-pokemon-extension/src/codegen/tables/EnergySource.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { Plant, PlantData } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { entityIsEnergySource, entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { getVoxelBodyPhysicsFromCaller, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";

uint256 constant ENERGY_REQUIRED_FOR_SPROUT = 100;
uint256 constant ENERGY_REQUIRED_FOR_FLOWER = 1000;

contract PlantSystem is SingleVoxelInteraction {
  function runSingleInteraction(
    address callerAddress,
    bytes32 plantEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    changedEntity = false;
    uint energyThreshold = 100; // Energy threshold to transition to Young Plant
    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(plantEntity);
    PlantData memory plantData = Plant.get(callerAddress, plantEntity);
    bool isNeighbourPlant = entityIsPlant(callerAddress, compareEntity);
    PlantStage neighbourPlantStage = Plant.getStage(callerAddress, compareEntity);

    (plantData, changedEntity, entityData) = updatePlantStage(entityBodyPhysics, plantData, entityData);
    if (entityData.length > 0) {
      return (changedEntity, entityData);
    }

    VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), compareEntity);

    if (plantData.stage == PlantStage.Sprout) {
      if (plantData.lastEnergy == entityBodyPhysics.energy) {
        // No energy change
        return (changedEntity, entityData);
      }
      plantData.lastEnergy = entityBodyPhysics.energy;
      changedEntity = true;

      uint256 youngPlantEnergy = entityBodyPhysics.energy;
      uint256 transferPercentage = youngPlantEnergy > 500 ? 15 : 5;

      // If the neighbor is a Seed cell and is beside the Young Plant
      if (
        isNeighbourPlant &&
        neighbourPlantStage == PlantStage.Seed &&
        compareBlockDirection != BlockDirection.Down &&
        compareBlockDirection != BlockDirection.Up
      ) {
        uint256 transferEnergyToSeed = (youngPlantEnergy * transferPercentage) / 100; // Transfer 20% of its energy to Seed
        entityData = abi.encode(transferEnergy(neighbourCoord, transferEnergyToSeed));
        entityBodyPhysics.energy -= transferEnergyToSeed;
        (plantData, changedEntity, entityData) = updatePlantStage(entityBodyPhysics, plantData, entityData);
      }
    } else if (plantData.stage == PlantStage.Flower) {
      uint harvestPlantEnergy = entityBodyPhysics.energy;

      // If the neighbor is a Pokemon cell
      if (harvestPlantEnergy > 0 && entityIsPokemon(compareEntity)) {
        // Transfer all energy to Pokemon
        entityData = abi.encode(transferEnergy(neighbourCoord, harvestPlantEnergy));
        entityBodyPhysics.energy -= harvestPlantEnergy;
        (plantData, changedEntity, entityData) = updatePlantStage(entityBodyPhysics, plantData, entityData);
        changedEntity = true;
      }
    }

    if (changedEntity) {
      Plant.set(callerAddress, plantEntity, plantData);
    }
    return (changedEntity, entityData);
  }

  function die(BodyPhysicsData memory bodyPhysicsData) internal returns (CAEventData memory) {
    return
      CAEventData({
        eventType: CAEventType.FluxEnergyAndMass,
        newCoord: VoxelCoord({ x: 0, y: 0, z: 0 }),
        energyFluxAmount: bodyPhysicsData.energy,
        massFluxAmount: bodyPhysicsData.mass
      });
  }

  function updatePlantStage(
    BodyPhysicsData memory entityBodyPhysics,
    PlantData memory plantData,
    bytes memory entityData
  ) internal returns (PlantData memory, bool changedEntity, bytes memory) {
    if (entityBodyPhysics.energy < ENERGY_REQUIRED_FOR_SPROUT) {
      if (plantData.stage == PlantStage.Sprout) {
        entityData = abi.encode(die(entityBodyPhysics));
        changedEntity = true;
      } else if (plantData.stage == PlantStage.Harvest) {
        plantData.stage = PlantStage.Seed;
        changedEntity = true;
      }
    } else if (
      entityBodyPhysics.energy >= ENERGY_REQUIRED_FOR_SPROUT && entityBodyPhysics.energy < ENERGY_REQUIRED_FOR_FLOWER
    ) {
      if (plantData.stage == PlantStage.Seed) {
        plantData.stage = PlantStage.Sprout;
        changedEntity = true;
      }
    } else {
      if (plantData.stage != PlantStage.Flower) {
        plantData.stage = PlantStage.Flower;
        changedEntity = true;
      }
    }

    return (plantData, changedEntity, entityData);
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    return entityIsPlant(callerAddress, entityId);
  }

  function eventHandlerPlant(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory, bytes[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
