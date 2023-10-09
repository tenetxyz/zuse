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
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict, caEntityToEntity } from "@tenet-base-ca/src/Utils.sol";
import { getEntitySimData, transfer } from "@tenet-level1-ca/src/Utils.sol";
import { console } from "forge-std/console.sol";

uint256 constant AMOUNT_REQUIRED_FOR_SPROUT = 10;
uint256 constant AMOUNT_REQUIRED_FOR_FLOWER = 30;

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

    BodySimData memory entitySimData = getEntitySimData(neighbourEntityId);
    PlantData memory plantData = Plant.get(callerAddress, neighbourEntityId);
    PlantStage oldPlantStage = plantData.stage;

    updatePlantStage(neighbourEntityId, entitySimData, plantData, entityData);
    if (plantData.stage != oldPlantStage) {
      changedEntity = true;
      return (changedEntity, entityData);
    }

    if (plantData.stage == PlantStage.Sprout) {
      uint256 transferNutrientsToSeed = getNutrientsToPlant(entitySimData.nutrients);
      if (transferNutrientsToSeed == 0) {
        return (changedEntity, entityData);
      }
      if (!isValidPlantNeighbour(callerAddress, centerEntityId, centerBlockDirection)) {
        return (changedEntity, entityData);
      }

      changedEntity = true;
    } else if (plantData.stage == PlantStage.Flower) {
      (uint harvestPlantElixir, uint harvestPlantProtein) = getFoodToPokemon(entitySimData.elixir, entityData.protein);
      if (harvestPlantElixir == 0 && harvestPlantProtein == 0) {
        return (changedEntity, entityData);
      }
      if (entitySimData.nutrients == 0) {
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
    BodySimData memory entitySimData = getEntitySimData(interactEntity);
    PlantData memory plantData = Plant.get(callerAddress, interactEntity);

    (plantData, changedEntity, entityData) = updatePlantStage(interactEntity, entitySimData, plantData, entityData);
    if (entityData.length > 0) {
      plantData.lastInteractionBlock = block.number;
      Plant.set(callerAddress, interactEntity, plantData);
      return (changedEntity, entityData);
    }

    CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length);

    bool hasTransfer = false;

    if (plantData.stage == PlantStage.Sprout) {
      (plantData, allCAEventData, hasTransfer) = runSproutInteraction(
        callerAddress,
        interactEntity,
        neighbourEntityIds,
        neighbourEntityDirections,
        entitySimData,
        plantData
      );
    } else if (plantData.stage == PlantStage.Flower) {
      (plantData, allCAEventData, hasTransfer) = runFlowerInteraction(
        callerAddress,
        interactEntity,
        neighbourEntityIds,
        entitySimData,
        plantData
      );
    }

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

  function runSproutInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    BodySimData memory entitySimData,
    PlantData memory plantData
  ) internal returns (PlantData memory, CAEventData[] memory, bool) {
    CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length);

    uint256 transferNutrientsToSeed = getNutrientsToPlant(entitySimData.nutrients);
    if (transferNutrientsToSeed == 0) {
      return (plantData, allCAEventData, false);
    }

    uint256 numSeedNeighbours = calculateNumSeedNeighbours(
      callerAddress,
      neighbourEntityIds,
      neighbourEntityDirections
    );

    bool hasTransfer = false;

    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }

      if (isValidPlantNeighbour(callerAddress, neighbourEntityIds[i], neighbourEntityDirections[i])) {
        VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);
        uint256 transferAmount = transferNutrientsToSeed / numSeedNeighbours;
        allCAEventData[i] = transfer(
          SimTable.Nutrients,
          SimTable.Nutrients,
          entitySimData,
          neighbourEntityIds[i],
          neighbourCoord,
          transferAmount
        );
        if (transferAmount > 0) {
          hasTransfer = true;
        }
      }
    }

    if (numSeedNeighbours > 0) {
      plantData.lastInteractionBlock = block.number;
    }

    return (plantData, allCAEventData, hasTransfer);
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
    BodySimData memory entitySimData,
    PlantData memory plantData
  ) internal returns (PlantData memory, CAEventData[] memory allCAEventData, bool) {
    if (entitySimData.nutrients > 0) {
      allCAEventData = new CAEventData[](2);
      VoxelCoord memory coord = getCAEntityPositionStrict(IStore(_world()), interactEntity);
      allCAEventData[0] = transfer(
        SimTable.Nutrients,
        SimTable.Elixir,
        entitySimData,
        interactEntity,
        coord,
        entitySimData.nutrients / 2
      );
      allCAEventData[1] = transfer(
        SimTable.Nutrients,
        SimTable.Protein,
        entitySimData,
        interactEntity,
        coord,
        entitySimData.nutrients / 2
      );
      return (plantData, allCAEventData, true);
    }

    allCAEventData = new CAEventData[](neighbourEntityIds.length * 2);

    uint256 elixirTransferAmount;
    uint256 proteinTransferAmount;
    uint256 numPokemonNeighbours;
    {
      (uint harvestPlantElixir, uint harvestPlantProtein) = getFoodToPokemon(entitySimData.elixir, entityData.protein);
      if (harvestPlantElixir == 0 && harvestPlantProtein == 0) {
        return (plantData, allCAEventData, false);
      }
      numPokemonNeighbours = calculateNumPokemonNeighbours(callerAddress, neighbourEntityIds);
      if (numPokemonNeighbours == 0) {
        return (plantData, allCAEventData, false);
      }
      elixirTransferAmount = harvestPlantElixir / numPokemonNeighbours;
      proteinTransferAmount = harvestPlantProtein / numPokemonNeighbours;
    }

    bool hasTransfer = false;

    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }

      // If the neighbor is a Pokemon cell
      if (entityIsPokemon(callerAddress, neighbourEntityIds[i])) {
        VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);
        {
          allCAEventData[i * 2] = transfer(
            SimTable.Elixir,
            SimTable.Health,
            entitySimData,
            neighbourEntityIds[i],
            neighbourCoord,
            elixirTransferAmount
          );
        }
        {
          allCAEventData[(i * 2) + 1] = transfer(
            SimTable.Protein,
            SimTable.Stamina,
            entitySimData,
            neighbourEntityIds[i],
            neighbourCoord,
            proteinTransferAmount
          );
        }

        if (elixirTransferAmount > 0 || proteinTransferAmount > 0) {
          hasTransfer = true;
        }
      }
    }

    if (numPokemonNeighbours > 0) {
      plantData.lastInteractionBlock = block.number;
    }

    return (plantData, allCAEventData, hasTransfer);
  }

  function dieData(
    bytes32 interactEntity,
    BodySimData memory entitySimData
  ) internal view returns (CAEventData[] memory) {
    CAEventData[] memory allCAEventData = new CAEventData[](2);
    VoxelEntity memory entity = VoxelEntity({ scale: 1, entityId: caEntityToEntity(interactEntity) });
    VoxelCoord memory coord = getCAEntityPositionStrict(IStore(_world()), interactEntity);

    SimEventData memory massEventData = SimEventData({
      senderTable: SimTable.Mass,
      senderValue: abi.encode(uint256ToNegativeInt256(entitySimData.mass)),
      targetEntity: entity,
      targetCoord: coord,
      targetTable: SimTable.Mass,
      targetValue: abi.encode(uint256ToNegativeInt256(entitySimData.mass))
    });
    allCAEventData[0] = CAEventData({ eventType: CAEventType.SimEvent, eventData: abi.encode(massEventData) });

    SimEventData memory energyEventData = SimEventData({
      senderTable: SimTable.Energy,
      senderValue: abi.encode(uint256ToNegativeInt256(entitySimData.energy)),
      targetEntity: entity,
      targetCoord: coord,
      targetTable: SimTable.Energy,
      targetValue: abi.encode(uint256ToNegativeInt256(entitySimData.energy))
    });
    allCAEventData[1] = CAEventData({ eventType: CAEventType.SimEvent, eventData: abi.encode(energyEventData) });
    return allCAEventData;
  }

  function updatePlantStage(
    bytes32 interactEntity,
    BodySimData memory entitySimData,
    PlantData memory plantData,
    bytes memory entityData
  ) internal view returns (PlantData memory, bool changedEntity, bytes memory) {
    uint256 totalNutrients = entitySimData.nutrients + entitySimData.elixir + entitySimData.protein;
    if (totalNutrients < AMOUNT_REQUIRED_FOR_SPROUT) {
      if (plantData.stage == PlantStage.Sprout) {
        plantData.stage = PlantStage.Seed;
        entityData = abi.encode(dieData(interactEntity, entitySimData));
      } else if (plantData.stage == PlantStage.Flower) {
        plantData.stage = PlantStage.Seed;
      }
    } else if (totalNutrients >= AMOUNT_REQUIRED_FOR_SPROUT && totalNutrients < AMOUNT_REQUIRED_FOR_FLOWER) {
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
