// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelInteraction } from "@tenet-base-ca/src/prototypes/VoxelInteraction.sol";
import { BlockDirection, BodyPhysicsData, CAEventData, CAEventType, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { EnergySource } from "@tenet-pokemon-extension/src/codegen/tables/EnergySource.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { Plant, PlantData } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { entityIsEnergySource, entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { getVoxelBodyPhysicsFromCaller, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";
import { console } from "forge-std/console.sol";

uint256 constant ENERGY_REQUIRED_FOR_SPROUT = 100;
uint256 constant ENERGY_REQUIRED_FOR_FLOWER = 200;

contract PlantSystem is VoxelInteraction {
  function onNewNeighbour(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(interactEntity);
    uint256 lastEnergy = Plant.getLastEnergy(callerAddress, interactEntity);
    if (lastEnergy == entityBodyPhysics.energy) {
      // No energy change, so don't run
      return (changedEntity, entityData);
    }
    // otherwise, there's been an energy change, so run
    changedEntity = true;

    return (changedEntity, entityData);
  }

  function runInteraction(
    address callerAddress,
    bytes32 plantEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(plantEntity);
    PlantData memory plantData = Plant.get(callerAddress, plantEntity);
    if (plantData.lastEnergy == entityBodyPhysics.energy) {
      // No energy change
      return (changedEntity, entityData);
    }
    plantData.lastEnergy = entityBodyPhysics.energy;

    (plantData, changedEntity, entityData) = updatePlantStage(entityBodyPhysics, plantData, entityData);
    if (entityData.length > 0) {
      Plant.set(callerAddress, plantEntity, plantData);
      return (changedEntity, entityData);
    }

    CAEventData memory transferData = CAEventData({
      eventType: CAEventType.FluxEnergy,
      newCoords: new VoxelCoord[](neighbourEntityIds.length),
      energyFluxAmounts: new uint256[](neighbourEntityIds.length),
      massFluxAmount: 0
    });

    bool hasTransfer;

    if (plantData.stage == PlantStage.Sprout) {
      transferData = runSproutInteraction(
        callerAddress,
        plantEntity,
        neighbourEntityIds,
        neighbourEntityDirections,
        entityBodyPhysics
      );
    } else if (plantData.stage == PlantStage.Flower) {
      transferData = runFlowerInteraction(
        callerAddress,
        plantEntity,
        neighbourEntityIds,
        neighbourEntityDirections,
        entityBodyPhysics
      );
    }

    for (uint i = 0; i < transferData.newCoords.length; i++) {
      if (transferData.energyFluxAmounts[i] > 0) {
        hasTransfer = true;
      }
    }

    // Check if there's at least one transfer
    if (hasTransfer) {
      entityData = abi.encode(transferData);
    }

    Plant.set(callerAddress, plantEntity, plantData);
    // Note: we don't need to set changedEntity to true, because we don't need another event

    return (changedEntity, entityData);
  }

  function runSproutInteraction(
    address callerAddress,
    bytes32 plantEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    BodyPhysicsData memory entityBodyPhysics
  ) internal view returns (CAEventData memory) {
    CAEventData memory transferData = CAEventData({
      eventType: CAEventType.FluxEnergy,
      newCoords: new VoxelCoord[](neighbourEntityIds.length),
      energyFluxAmounts: new uint256[](neighbourEntityIds.length),
      massFluxAmount: 0
    });

    uint256 transferPercentage = entityBodyPhysics.energy > 500 ? 15 : 5;
    uint256 transferEnergyToSeed = (entityBodyPhysics.energy * transferPercentage) / 100;
    if (transferEnergyToSeed == 0) {
      return transferData;
    }

    uint256 numSeedNeighbours = 0;

    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }

      if (
        entityIsPlant(callerAddress, neighbourEntityIds[i]) &&
        Plant.getStage(callerAddress, neighbourEntityIds[i]) == PlantStage.Seed &&
        neighbourEntityDirections[i] != BlockDirection.Down &&
        neighbourEntityDirections[i] != BlockDirection.Up
      ) {
        numSeedNeighbours += 1;
        VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);
        transferData.newCoords[i] = neighbourCoord;
        transferData.energyFluxAmounts[i] = 1;
      }
    }

    for (uint i = 0; i < transferData.newCoords.length; i++) {
      if (transferData.energyFluxAmounts[i] == 1) {
        transferData.energyFluxAmounts[i] = transferEnergyToSeed / numSeedNeighbours;
      }
    }

    return transferData;
  }

  function runFlowerInteraction(
    address callerAddress,
    bytes32 plantEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    BodyPhysicsData memory entityBodyPhysics
  ) internal view returns (CAEventData memory) {
    CAEventData memory transferData = CAEventData({
      eventType: CAEventType.FluxEnergy,
      newCoords: new VoxelCoord[](neighbourEntityIds.length),
      energyFluxAmounts: new uint256[](neighbourEntityIds.length),
      massFluxAmount: 0
    });

    uint harvestPlantEnergy = entityBodyPhysics.energy;
    if (harvestPlantEnergy == 0) {
      return transferData;
    }

    uint256 numPokemonNeighbours = 0;

    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }

      // If the neighbor is a Pokemon cell
      if (entityIsPokemon(callerAddress, neighbourEntityIds[i])) {
        numPokemonNeighbours += 1;
        VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);
        transferData.newCoords[i] = neighbourCoord;
        transferData.energyFluxAmounts[i] = 1;
      }
    }

    for (uint i = 0; i < transferData.newCoords.length; i++) {
      if (transferData.energyFluxAmounts[i] == 1) {
        transferData.energyFluxAmounts[i] = harvestPlantEnergy / numPokemonNeighbours;
      }
    }

    return transferData;
  }

  function dieData(BodyPhysicsData memory bodyPhysicsData) internal pure returns (CAEventData memory) {
    uint256[] memory energyFluxAmounts = new uint256[](1);
    energyFluxAmounts[0] = bodyPhysicsData.energy;
    return
      CAEventData({
        eventType: CAEventType.FluxEnergyAndMass,
        newCoords: new VoxelCoord[](0),
        energyFluxAmounts: energyFluxAmounts,
        massFluxAmount: bodyPhysicsData.mass
      });
  }

  function updatePlantStage(
    BodyPhysicsData memory entityBodyPhysics,
    PlantData memory plantData,
    bytes memory entityData
  ) internal view returns (PlantData memory, bool changedEntity, bytes memory) {
    if (entityBodyPhysics.energy < ENERGY_REQUIRED_FOR_SPROUT) {
      if (plantData.stage == PlantStage.Sprout) {
        entityData = abi.encode(dieData(entityBodyPhysics));
      } else if (plantData.stage == PlantStage.Flower) {
        plantData.stage = PlantStage.Seed;
      }
    } else if (
      entityBodyPhysics.energy >= ENERGY_REQUIRED_FOR_SPROUT && entityBodyPhysics.energy < ENERGY_REQUIRED_FOR_FLOWER
    ) {
      if (plantData.stage == PlantStage.Seed) {
        plantData.stage = PlantStage.Sprout;
      }
    } else {
      if (plantData.stage != PlantStage.Flower) {
        plantData.stage = PlantStage.Flower;
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
