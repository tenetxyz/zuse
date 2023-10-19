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
import { PlantStage, EventType } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { entityIsSoil, entityIsPlant, entityIsPokemon, entityIsFarmer } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict, caEntityToEntity } from "@tenet-base-ca/src/Utils.sol";
import { Farmer } from "@tenet-pokemon-extension/src/codegen/tables/Farmer.sol";
import { getEntitySimData, transfer, transferSimData } from "@tenet-level1-ca/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { PlantConsumer } from "@tenet-pokemon-extension/src/Types.sol";

uint256 constant AMOUNT_REQUIRED_FOR_SPROUT = 10;
uint256 constant AMOUNT_REQUIRED_FOR_FLOWER = 30;

contract PlantSystem is VoxelInteraction {
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
    if (!entityIsPokemon(callerAddress, centerEntityId)) {
      return (changedEntity, entityData);
    }

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

  function updateTotalProduced(address callerAddress, bytes32 interactEntity) internal {
    uint256 totalProduced = Plant.getTotalProduced(callerAddress, interactEntity);
    uint256 totalConsumed = Plant.getTotalConsumed(callerAddress, interactEntity);
    BodySimData memory entitySimData = getEntitySimData(interactEntity);
    // we add totalConsumed since these were still produced by the plant
    uint256 currentProduced = entitySimData.elixir + entitySimData.protein + totalConsumed;
    if (currentProduced > totalProduced) {
      Plant.setTotalProduced(callerAddress, interactEntity, currentProduced);
    }
  }

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    updateTotalProduced(callerAddress, interactEntity);
    uint256 lastInteractionBlock = Plant.getLastInteractionBlock(callerAddress, interactEntity);
    if (block.number == lastInteractionBlock) {
      return (changedEntity, entityData);
    }
    BodySimData memory entitySimData = getEntitySimData(interactEntity);
    if (!entitySimData.hasNitrogen || !entitySimData.hasPhosphorous || !entitySimData.hasPotassium) {
      return initPlantProperties(callerAddress, interactEntity, entitySimData);
    }

    PlantData memory plantData = Plant.get(callerAddress, interactEntity);

    // (plantData, changedEntity, entityData) = updatePlantStage(interactEntity, entitySimData, plantData, entityData);
    // if (entityData.length > 0) {
    //   Plant.set(callerAddress, interactEntity, plantData);
    //   return (changedEntity, entityData);
    // }

    CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length);

    bool hasTransfer = false;

    // if (plantData.stage == PlantStage.Sprout) {
    //   (plantData, allCAEventData, hasTransfer) = runSproutInteraction(
    //     callerAddress,
    //     interactEntity,
    //     neighbourEntityIds,
    //     neighbourEntityDirections,
    //     entitySimData,
    //     plantData
    //   );
    // } else if (plantData.stage == PlantStage.Flower) {
    //   (plantData, allCAEventData, hasTransfer) = runFlowerInteraction(
    //     callerAddress,
    //     interactEntity,
    //     neighbourEntityIds,
    //     entitySimData,
    //     plantData
    //   );
    // }

    (plantData, allCAEventData, hasTransfer) = runFlowerInteraction(
      callerAddress,
      interactEntity,
      neighbourEntityIds,
      entitySimData,
      plantData
    );

    // Check if there's at least one transfer
    if (hasTransfer) {
      entityData = abi.encode(allCAEventData);
    }

    Plant.set(callerAddress, interactEntity, plantData);
    // Note: we don't need to set changedEntity to true, because we don't need another event

    return (changedEntity, entityData);
  }

  function initPlantProperties(
    address callerAddress,
    bytes32 interactEntity,
    BodySimData memory entitySimData
  ) internal returns (bool changedEntity, bytes memory entityData) {
    EventType lastEventType = Plant.getLastEvent(callerAddress, interactEntity);
    VoxelEntity memory entity = VoxelEntity({ scale: 1, entityId: caEntityToEntity(interactEntity) });
    VoxelCoord memory coord = getCAEntityPositionStrict(IStore(_world()), interactEntity);

    if (lastEventType != EventType.SetNPK) {
      console.log("setNPKSimEvent soil NPK");
      console.logBytes32(interactEntity);
      SimEventData[] memory allSimEventData = new SimEventData[](3);
      allSimEventData[0] = SimEventData({
        senderTable: SimTable.Nitrogen,
        senderValue: abi.encode(0),
        targetEntity: entity,
        targetCoord: coord,
        targetTable: SimTable.Nitrogen,
        targetValue: abi.encode(30)
      });
      allSimEventData[1] = SimEventData({
        senderTable: SimTable.Phosphorous,
        senderValue: abi.encode(0),
        targetEntity: entity,
        targetCoord: coord,
        targetTable: SimTable.Phosphorous,
        targetValue: abi.encode(30)
      });
      allSimEventData[2] = SimEventData({
        senderTable: SimTable.Potassium,
        senderValue: abi.encode(0),
        targetEntity: entity,
        targetCoord: coord,
        targetTable: SimTable.Potassium,
        targetValue: abi.encode(30)
      });

      CAEventData[] memory allCAEventData = new CAEventData[](1);
      allCAEventData[0] = CAEventData({ eventType: CAEventType.BatchSimEvent, eventData: abi.encode(allSimEventData) });
      entityData = abi.encode(allCAEventData);
      Plant.setLastEvent(callerAddress, interactEntity, EventType.SetNPK);
      return (changedEntity, entityData);
    }

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

  function entityHasNPK(bytes32 interactEntity) internal returns (bool) {
    BodySimData memory entitySimData = getEntitySimData(interactEntity);
    return entitySimData.hasNitrogen && entitySimData.hasPhosphorous && entitySimData.hasPotassium;
  }

  function runSproutInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    BodySimData memory entitySimData,
    PlantData memory plantData
  ) internal returns (PlantData memory, CAEventData[] memory allCAEventData, bool hasTransfer) {
    allCAEventData = new CAEventData[](neighbourEntityIds.length);
    console.log("runSproutInteraction");

    uint256 transferAmount;
    {
      uint256 transferNutrientsToSeed = getNutrientsToPlant(entitySimData.nutrients);
      if (transferNutrientsToSeed == 0) {
        return (plantData, allCAEventData, false);
      }

      uint256 numSeedNeighbours = calculateNumSeedNeighbours(
        callerAddress,
        neighbourEntityIds,
        neighbourEntityDirections
      );
      if (numSeedNeighbours > 0) {
        transferAmount = transferNutrientsToSeed / numSeedNeighbours;
      }
      if (transferAmount == 0) {
        plantData.lastInteractionBlock = block.number;
        return (plantData, allCAEventData, false);
      }
    }

    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }

      if (
        isValidPlantNeighbour(callerAddress, neighbourEntityIds[i], neighbourEntityDirections[i]) &&
        entityHasNPK(neighbourEntityIds[i])
      ) {
        {
          allCAEventData[i] = transfer(
            SimTable.Nutrients,
            SimTable.Nutrients,
            entitySimData,
            neighbourEntityIds[i],
            getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]),
            transferAmount
          );
        }
        plantData.lastInteractionBlock = block.number;
        hasTransfer = true;
      }
    }

    return (plantData, allCAEventData, hasTransfer);
  }

  function calculateEatingNeighbours(
    address callerAddress,
    bytes32[] memory neighbourEntityIds
  ) internal view returns (uint256 numEatingNeighbours) {
    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }
      // Check if the neighbor is a Soil, Seed, or Young Plant cell
      if (entityIsPokemon(callerAddress, neighbourEntityIds[i])) {
        numEatingNeighbours += 1;
      } else if (entityIsFarmer(callerAddress, neighbourEntityIds[i])) {
        if (Farmer.getIsHungry(callerAddress, neighbourEntityIds[i])) {
          numEatingNeighbours += 1;
        }
      }
    }
    return numEatingNeighbours;
  }

  function addPlantConsumer(PlantData memory plantData, bytes32 consumerEntity) internal returns (PlantData memory) {
    PlantConsumer[] memory currentConsumers = abi.decode(plantData.consumers, (PlantConsumer[]));
    PlantConsumer[] memory newConsumers = new PlantConsumer[](currentConsumers.length + 1);
    for (uint i = 0; i < currentConsumers.length; i++) {
      newConsumers[i] = currentConsumers[i];
    }
    newConsumers[currentConsumers.length] = PlantConsumer({
      entityId: consumerEntity,
      consumedBlockNumber: block.number
    });
    plantData.consumers = abi.encode(newConsumers);
    return plantData;
  }

  function runFlowerInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BodySimData memory entitySimData,
    PlantData memory plantData
  ) internal returns (PlantData memory, CAEventData[] memory allCAEventData, bool) {
    allCAEventData = new CAEventData[](neighbourEntityIds.length);

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
          hasTransfer = true;
          plantData = addPlantConsumer(plantData, neighbourEntityIds[i]);
          // plantData.totalConsumed += elixirTransferAmount + proteinTransferAmount;
          console.log("new plantData.totalConsumed");
          console.logUint(plantData.totalConsumed);
        }
      }
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
      senderValue: abi.encode(uint256ToNegativeInt256(entitySimData.energy + entitySimData.nutrients)),
      targetEntity: entity,
      targetCoord: coord,
      targetTable: SimTable.Energy,
      targetValue: abi.encode(uint256ToNegativeInt256(entitySimData.energy + entitySimData.nutrients))
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
        if (plantData.lastEvent != EventType.Die) {
          entityData = abi.encode(dieData(interactEntity, entitySimData));
          plantData.lastEvent = EventType.Die;
        }
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
