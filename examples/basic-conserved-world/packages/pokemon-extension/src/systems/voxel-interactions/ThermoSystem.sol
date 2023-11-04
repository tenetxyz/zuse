// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelInteraction } from "@tenet-base-ca/src/prototypes/VoxelInteraction.sol";
import { VoxelEntity, BlockDirection, BodySimData, CAEventData, CAEventType, SimEventData, SimTable, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { uint256ToNegativeInt256, uint256ToInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { CAEntityReverseMapping, CAEntityReverseMappingTableId, CAEntityReverseMappingData } from "@tenet-base-ca/src/codegen/tables/CAEntityReverseMapping.sol";
import { Plant, PlantData } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { Thermo } from "@tenet-pokemon-extension/src/codegen/tables/Thermo.sol";
import { PlantStage, EventType } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { entityIsSoil, entityIsPlant, entityIsPokemon, entityIsFarmer } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict, caEntityToEntity } from "@tenet-base-ca/src/Utils.sol";
import { Farmer } from "@tenet-pokemon-extension/src/codegen/tables/Farmer.sol";
import { getEntitySimData, transfer, transferSimData } from "@tenet-level1-ca/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { PlantConsumer } from "@tenet-pokemon-extension/src/Types.sol";

contract ThermoSystem is VoxelInteraction {
  function onNewNeighbour(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId,
    BlockDirection centerBlockDirection
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    updateTotalProduced(callerAddress, neighbourEntityId);
    uint256 lastInteractionBlock = Plant.getLastInteractionBlock(callerAddress, neighbourEntityId);
    if (block.number == lastInteractionBlock) {
      return (changedEntity, entityData);
    }

    BodySimData memory entitySimData = getEntitySimData(neighbourEntityId);
    if (!entitySimData.hasNitrogen || !entitySimData.hasPhosphorous || !entitySimData.hasPotassium) {
      return initPlantProperties(callerAddress, neighbourEntityId, entitySimData);
    }

    // PlantData memory plantData = Plant.get(callerAddress, neighbourEntityId);

    (uint harvestPlantElixir, uint harvestPlantProtein) = getFoodToPokemon(entitySimData.elixir, entitySimData.protein);
    if (harvestPlantElixir == 0 && harvestPlantProtein == 0) {
      return (changedEntity, entityData);
    }
    // if (entitySimData.nutrients == 0) {
    //   return (changedEntity, entityData);
    // }
    console.log("checking");
    if (
      !(entityIsPokemon(callerAddress, centerEntityId) ||
        (entityIsFarmer(callerAddress, centerEntityId) && Farmer.getIsHungry(callerAddress, centerEntityId)))
    ) {
      return (changedEntity, entityData);
    }
    console.log("changed true");

    changedEntity = true;

    // PlantStage oldPlantStage = plantData.stage;

    // updatePlantStage(neighbourEntityId, entitySimData, plantData, entityData);
    // if (plantData.stage != oldPlantStage) {
    //   changedEntity = true;
    //   return (changedEntity, entityData);
    // }

    // if (plantData.stage == PlantStage.Sprout) {
    //   uint256 transferNutrientsToSeed = getNutrientsToPlant(entitySimData.nutrients);
    //   if (transferNutrientsToSeed == 0) {
    //     return (changedEntity, entityData);
    //   }
    //   if (!isValidPlantNeighbour(callerAddress, centerEntityId, centerBlockDirection)) {
    //     return (changedEntity, entityData);
    //   }

    //   changedEntity = true;
    // } else if (plantData.stage == PlantStage.Flower) {

    // }

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
    BodySimData memory entitySimData = getEntitySimData(interactEntity);

    PlantData memory plantData = Plant.get(callerAddress, interactEntity);

    CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length);

    allCAEventData = new CAEventData[](neighbourEntityIds.length);
    console.log("runFlowerInteraction");

    uint256 elixirTransferAmount;
    uint256 proteinTransferAmount;
    {
      (uint harvestPlantElixir, uint harvestPlantProtein) = getFoodToPokemon(
        entitySimData.elixir,
        entitySimData.protein
      );
      if (harvestPlantElixir == 0 && harvestPlantProtein == 0) {
        return (plantData, allCAEventData, false);
      }
      uint256 numEatingNeighbours = calculateEatingNeighbours(callerAddress, neighbourEntityIds);
      console.logUint(numEatingNeighbours);
      if (numEatingNeighbours == 0) {
        return (plantData, allCAEventData, false);
      }
      elixirTransferAmount = harvestPlantElixir / numEatingNeighbours;
      proteinTransferAmount = harvestPlantProtein / numEatingNeighbours;
      if (numEatingNeighbours > 0) {
        plantData.lastInteractionBlock = block.number;
      }
    }

    bool hasTransfer = false;

    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }

      // If the neighbor is a Pokemon cell
      if (
        entityIsPokemon(callerAddress, neighbourEntityIds[i]) ||
        (entityIsFarmer(callerAddress, neighbourEntityIds[i]) &&
          Farmer.getIsHungry(callerAddress, neighbourEntityIds[i]))
      ) {
        VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);
        SimEventData[] memory allSimEventData = new SimEventData[](
          elixirTransferAmount > 0 && proteinTransferAmount > 0 ? 2 : 1
        );
        console.log("transferring");
        if (elixirTransferAmount > 0 && proteinTransferAmount > 0) {
          allSimEventData[0] = transferSimData(
            SimTable.Elixir,
            SimTable.Health,
            entitySimData,
            neighbourEntityIds[i],
            neighbourCoord,
            elixirTransferAmount
          );
          allSimEventData[1] = transferSimData(
            SimTable.Protein,
            SimTable.Stamina,
            entitySimData,
            neighbourEntityIds[i],
            neighbourCoord,
            proteinTransferAmount
          );
        } else if (elixirTransferAmount > 0) {
          allSimEventData[0] = transferSimData(
            SimTable.Elixir,
            SimTable.Health,
            entitySimData,
            neighbourEntityIds[i],
            neighbourCoord,
            elixirTransferAmount
          );
        } else {
          allSimEventData[0] = transferSimData(
            SimTable.Protein,
            SimTable.Stamina,
            entitySimData,
            neighbourEntityIds[i],
            neighbourCoord,
            proteinTransferAmount
          );
        }
        allCAEventData[i] = CAEventData({
          eventType: CAEventType.BatchSimEvent,
          eventData: abi.encode(allSimEventData)
        });

        if (elixirTransferAmount > 0 || proteinTransferAmount > 0) {
          console.log("set consumer");
          hasTransfer = true;
          plantData = addPlantConsumer(plantData, neighbourEntityIds[i]);
        }
      }
    }

    bool hasTransfer = false;

    // Check if there's at least one transfer
    if (hasTransfer) {
      entityData = abi.encode(allCAEventData);
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

  function getNutrientsToPlant(uint256 plantNutrients) internal pure returns (uint256) {
    uint256 transferPercentage = plantNutrients > 500 ? 15 : 5;
    return (plantNutrients * transferPercentage) / 100; // Transfer 20% of its energy to Plant
  }

  function getFoodToPokemon(uint256 plantElixir, uint256 plantProtein) internal pure returns (uint256, uint256) {
    return (plantElixir, plantProtein); // Transfer 100% of its food to Pokemon
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

  function eventHandlerThermo(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }

  function neighbourEventHandlerThermo(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public returns (bool, bytes memory) {
    return super.neighbourEventHandler(callerAddress, neighbourEntityId, centerEntityId);
  }
}
