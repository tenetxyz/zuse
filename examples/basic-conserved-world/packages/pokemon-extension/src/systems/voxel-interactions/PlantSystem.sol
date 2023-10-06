// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelInteraction } from "@tenet-base-ca/src/prototypes/VoxelInteraction.sol";
import { VoxelEntity, BlockDirection, BodyPhysicsData, SimEventData, SimTable, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { CAEntityReverseMapping, CAEntityReverseMappingTableId, CAEntityReverseMappingData } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { Plant, PlantData } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { getVoxelBodyPhysicsFromCaller, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";
import { console } from "forge-std/console.sol";

uint256 constant ENERGY_REQUIRED_FOR_SPROUT = 10;
uint256 constant ENERGY_REQUIRED_FOR_FLOWER = 30;

contract PlantSystem is VoxelInteraction {
  function onNewNeighbour(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId,
    BlockDirection centerBlockDirection
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    uint256 lastInteractionBlock = Plant.getLastInteractionBlock(callerAddress, neighbourEntityId);
    if (block.number == lastInteractionBlock) {
      return (changedEntity, entityData);
    }

    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(neighbourEntityId);
    PlantData memory plantData = Plant.get(callerAddress, neighbourEntityId);
    PlantStage oldPlantStage = plantData.stage;

    updatePlantStage(neighbourEntityId, entityBodyPhysics, plantData, entityData);
    if (plantData.stage != oldPlantStage) {
      changedEntity = true;
      return (changedEntity, entityData);
    }

    if (plantData.stage == PlantStage.Sprout) {
      uint256 transferEnergyToSeed = getEnergyToPlant(entityBodyPhysics.energy);
      if (transferEnergyToSeed == 0) {
        return (changedEntity, entityData);
      }
      if (!isValidPlantNeighbour(callerAddress, centerEntityId, centerBlockDirection)) {
        return (changedEntity, entityData);
      }

      changedEntity = true;
    } else if (plantData.stage == PlantStage.Flower) {
      uint256 transferEnergyToPokemon = getEnergyToPokemon(entityBodyPhysics.energy);
      if (transferEnergyToPokemon == 0) {
        return (changedEntity, entityData);
      }
      if (!entityIsPokemon(callerAddress, centerEntityId)) {
        return (changedEntity, entityData);
      }

      changedEntity = true;
    }

    return (changedEntity, entityData);
  }

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    uint256 lastInteractionBlock = Plant.getLastInteractionBlock(callerAddress, interactEntity);
    if (block.number == lastInteractionBlock) {
      return (changedEntity, entityData);
    }
    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(interactEntity);
    PlantData memory plantData = Plant.get(callerAddress, interactEntity);

    (plantData, changedEntity, entityData) = updatePlantStage(interactEntity, entityBodyPhysics, plantData, entityData);
    if (entityData.length > 0) {
      plantData.lastInteractionBlock = block.number;
      Plant.set(callerAddress, interactEntity, plantData);
      return (changedEntity, entityData);
    }

    SimEventData[] memory allSimEventData = new SimEventData[](neighbourEntityIds.length);

    bool hasTransfer;

    if (plantData.stage == PlantStage.Sprout) {
      (plantData, allSimEventData) = runSproutInteraction(
        callerAddress,
        interactEntity,
        neighbourEntityIds,
        neighbourEntityDirections,
        entityBodyPhysics,
        plantData
      );
    } else if (plantData.stage == PlantStage.Flower) {
      (plantData, allSimEventData) = runFlowerInteraction(
        callerAddress,
        interactEntity,
        neighbourEntityIds,
        neighbourEntityDirections,
        entityBodyPhysics,
        plantData
      );
    }

    for (uint i = 0; i < allSimEventData.length; i++) {
      if (allSimEventData[i].targetTable == SimTable.Energy) {
        if (abi.decode(allSimEventData[i].targetValue, (uint256)) > 0) {
          hasTransfer = true;
          break;
        }
      }
    }

    // Check if there's at least one transfer
    if (hasTransfer) {
      entityData = abi.encode(allSimEventData);
    }

    Plant.set(callerAddress, interactEntity, plantData);
    // Note: we don't need to set changedEntity to true, because we don't need another event

    return (changedEntity, entityData);
  }

  function isValidPlantNeighbour(
    address callerAddress,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal view returns (bool) {
    if (neighbourBlockDirection == BlockDirection.Down || neighbourBlockDirection == BlockDirection.Up) {
      return false;
    }

    if (!entityIsPlant(callerAddress, neighbourEntityId)) {
      return false;
    }

    PlantStage plantStage = Plant.getStage(callerAddress, neighbourEntityId);
    if (Plant.getStage(callerAddress, neighbourEntityId) != PlantStage.Seed) {
      return false;
    }

    return true;
  }

  function getEnergyToPlant(uint256 plantEnergy) internal pure returns (uint256) {
    uint256 transferPercentage = plantEnergy > 500 ? 15 : 5;
    return (plantEnergy * transferPercentage) / 100; // Transfer 20% of its energy to Plant
  }

  function getEnergyToPokemon(uint256 plantEnergy) internal pure returns (uint256) {
    return plantEnergy; // Transfer 100% of its energy to Pokemon
  }

  function calculateNumSeedNeighbours(
    address callerAddress,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections
  ) internal view returns (uint256 numSeedNeighbours) {
    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }
      // Check if the neighbor is a Soil, Seed, or Young Plant cell
      if (isValidPlantNeighbour(callerAddress, neighbourEntityIds[i], neighbourEntityDirections[i])) {
        numSeedNeighbours += 1;
      }
    }
    return numSeedNeighbours;
  }

  function runSproutInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    BodyPhysicsData memory entityBodyPhysics,
    PlantData memory plantData
  ) internal returns (PlantData memory, SimEventData[] memory) {
    SimEventData[] memory allSimEventData = new SimEventData[](neighbourEntityIds.length);

    uint256 transferEnergyToSeed = getEnergyToPlant(entityBodyPhysics.energy);
    if (transferEnergyToSeed == 0) {
      return (plantData, allSimEventData);
    }

    uint256 numSeedNeighbours = calculateNumSeedNeighbours(
      callerAddress,
      neighbourEntityIds,
      neighbourEntityDirections
    );

    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }

      if (isValidPlantNeighbour(callerAddress, neighbourEntityIds[i], neighbourEntityDirections[i])) {
        VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);
        allSimEventData[i] = transferEnergy(
          entityBodyPhysics,
          neighbourEntityIds[i],
          neighbourCoord,
          transferEnergyToSeed / numSeedNeighbours
        );
      }
    }

    if (numSeedNeighbours > 0) {
      plantData.lastInteractionBlock = block.number;
    }

    return (plantData, allSimEventData);
  }

  function calculateNumPokemonNeighbours(
    address callerAddress,
    bytes32[] memory neighbourEntityIds
  ) internal view returns (uint256 numPokemonNeighbours) {
    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }
      // Check if the neighbor is a Soil, Seed, or Young Plant cell
      if (entityIsPokemon(callerAddress, neighbourEntityIds[i])) {
        numPokemonNeighbours += 1;
      }
    }
    return numPokemonNeighbours;
  }

  function runFlowerInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    BodyPhysicsData memory entityBodyPhysics,
    PlantData memory plantData
  ) internal returns (PlantData memory, SimEventData[] memory) {
    SimEventData[] memory allSimEventData = new SimEventData[](neighbourEntityIds.length);

    uint harvestPlantEnergy = getEnergyToPokemon(entityBodyPhysics.energy);
    if (harvestPlantEnergy == 0) {
      return (plantData, allSimEventData);
    }

    uint256 numPokemonNeighbours = calculateNumPokemonNeighbours(callerAddress, neighbourEntityIds);

    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }

      // If the neighbor is a Pokemon cell
      if (entityIsPokemon(callerAddress, neighbourEntityIds[i])) {
        VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);
        allSimEventData[i] = transferEnergy(
          entityBodyPhysics,
          neighbourEntityIds[i],
          neighbourCoord,
          harvestPlantEnergy / numPokemonNeighbours
        );
      }
    }

    if (numPokemonNeighbours > 0) {
      plantData.lastInteractionBlock = block.number;
    }

    return (plantData, allSimEventData);
  }

  function dieData(
    bytes32 interactEntity,
    BodyPhysicsData memory bodyPhysicsData
  ) internal view returns (SimEventData[] memory) {
    SimEventData[] memory allSimEventData = new SimEventData[](2);
    CAEntityReverseMappingData memory entityData = CAEntityReverseMapping.get(interactEntity);
    VoxelEntity memory entity = VoxelEntity({ scale: 1, entityId: entityData.entity });
    VoxelCoord memory coord = getCAEntityPositionStrict(IStore(_world()), interactEntity);
    allSimEventData[0] = SimEventData({
      senderTable: SimTable.Energy,
      senderValue: abi.encode(bodyPhysicsData.energy),
      targetEntity: entity,
      targetCoord: coord,
      targetTable: SimTable.Energy,
      targetValue: abi.encode(uint256(0))
    });
    allSimEventData[1] = SimEventData({
      senderTable: SimTable.Mass,
      senderValue: abi.encode(bodyPhysicsData.mass),
      targetEntity: entity,
      targetCoord: coord,
      targetTable: SimTable.Mass,
      targetValue: abi.encode(uint256(0))
    });
    return allSimEventData;
  }

  function updatePlantStage(
    bytes32 interactEntity,
    BodyPhysicsData memory entityBodyPhysics,
    PlantData memory plantData,
    bytes memory entityData
  ) internal view returns (PlantData memory, bool changedEntity, bytes memory) {
    if (entityBodyPhysics.energy < ENERGY_REQUIRED_FOR_SPROUT) {
      if (plantData.stage == PlantStage.Sprout) {
        plantData.stage = PlantStage.Seed;
        entityData = abi.encode(dieData(interactEntity, entityBodyPhysics));
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

  function eventHandlerPlant(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }

  function neighbourEventHandlerPlant(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public returns (bool, bytes memory) {
    return super.neighbourEventHandler(callerAddress, neighbourEntityId, centerEntityId);
  }
}
