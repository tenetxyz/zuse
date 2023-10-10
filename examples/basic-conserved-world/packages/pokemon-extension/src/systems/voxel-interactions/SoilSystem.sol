// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelInteraction } from "@tenet-base-ca/src/prototypes/VoxelInteraction.sol";
import { BlockDirection, BodySimData, CAEventData, CAEventType, SimEventData, SimTable, VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { Plant } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { entityIsSoil, entityIsPlant } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict, caEntityToEntity } from "@tenet-base-ca/src/Utils.sol";
import { getEntitySimData, transfer } from "@tenet-level1-ca/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract SoilSystem is VoxelInteraction {
  function onNewNeighbour(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId,
    BlockDirection centerBlockDirection
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    uint256 lastInteractionBlock = Soil.getLastInteractionBlock(callerAddress, neighbourEntityId);
    if (block.number == lastInteractionBlock) {
      return (changedEntity, entityData);
    }

    BodySimData memory entitySimData = getEntitySimData(neighbourEntityId);
    if (entitySimData.nitrogen == 0 && entitySimData.phosphorous == 0 && entitySimData.potassium == 0) {
      return initSoilProperties(neighbourEntityId, entitySimData);
    }
    if (entitySimData.energy > 0) {
      // We convert all our general energy to nutrient energy
      entityData = getNutrientConversion(neighbourEntityId, entitySimData);
      return (changedEntity, entityData);
    }

    uint256 transferNutrientsToSoil = getNutrientsToSoil(entitySimData.nutrients);
    uint256 transferNutrientsToPlant = getNutrientsToPlant(entitySimData.nutrients);
    if (transferNutrientsToSoil == 0 && transferNutrientsToPlant == 0) {
      return (changedEntity, entityData);
    }

    if (
      !entityIsSoil(callerAddress, centerEntityId) &&
      !isValidPlantNeighbour(callerAddress, centerEntityId, centerBlockDirection)
    ) {
      return (changedEntity, entityData);
    }

    // otherwise, we want to run
    changedEntity = true;

    return (changedEntity, entityData);
  }

  function isValidPlantNeighbour(
    address callerAddress,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal returns (bool) {
    if (neighbourBlockDirection != BlockDirection.Down) {
      return false;
    }

    if (!entityIsPlant(callerAddress, neighbourEntityId)) {
      return false;
    }

    PlantStage plantStage = Plant.getStage(callerAddress, neighbourEntityId);
    if (plantStage != PlantStage.Seed && plantStage != PlantStage.Sprout) {
      return false;
    }

    return true;
  }

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    changedEntity = false;
    uint256 lastInteractionBlock = Soil.getLastInteractionBlock(callerAddress, interactEntity);
    if (block.number == lastInteractionBlock) {
      return (changedEntity, entityData);
    }

    BodySimData memory entitySimData = getEntitySimData(interactEntity);
    if (entitySimData.nitrogen == 0 && entitySimData.phosphorous == 0 && entitySimData.potassium == 0) {
      return initSoilProperties(interactEntity, entitySimData);
    }
    if (entitySimData.energy > 0) {
      // We convert all our general energy to nutrient energy
      entityData = getNutrientConversion(interactEntity, entitySimData);
      return (changedEntity, entityData);
    }

    entityData = getEntityData(
      callerAddress,
      interactEntity,
      neighbourEntityIds,
      neighbourEntityDirections,
      entitySimData
    );

    // Note: we don't need to set changedEntity to true, because we don't need another event

    return (changedEntity, entityData);
  }

  function initSoilProperties(
    bytes32 interactEntity,
    BodySimData memory entitySimData
  ) internal returns (bool changedEntity, bytes memory entityData) {
    CAEventData[] memory allCAEventData = new CAEventData[](3);
    VoxelEntity memory entity = VoxelEntity({ scale: 1, entityId: caEntityToEntity(interactEntity) });
    VoxelCoord memory coord = getCAEntityPositionStrict(IStore(_world()), interactEntity);
    console.log("setNPKSimEvent soil");
    console.logBytes32(interactEntity);

    SimEventData memory setNitrogenSimEvent = SimEventData({
      senderTable: SimTable.Nitrogen,
      senderValue: abi.encode(0),
      targetEntity: entity,
      targetCoord: coord,
      targetTable: SimTable.Nitrogen,
      targetValue: abi.encode(1)
    });
    allCAEventData[0] = CAEventData({ eventType: CAEventType.SimEvent, eventData: abi.encode(setNitrogenSimEvent) });

    SimEventData memory setPhosphorousSimEvent = SimEventData({
      senderTable: SimTable.Phosphorous,
      senderValue: abi.encode(0),
      targetEntity: entity,
      targetCoord: coord,
      targetTable: SimTable.Phosphorous,
      targetValue: abi.encode(1)
    });
    allCAEventData[1] = CAEventData({ eventType: CAEventType.SimEvent, eventData: abi.encode(setPhosphorousSimEvent) });

    SimEventData memory setPotassiumSimEvent = SimEventData({
      senderTable: SimTable.Potassium,
      senderValue: abi.encode(0),
      targetEntity: entity,
      targetCoord: coord,
      targetTable: SimTable.Potassium,
      targetValue: abi.encode(1)
    });
    allCAEventData[2] = CAEventData({ eventType: CAEventType.SimEvent, eventData: abi.encode(setPotassiumSimEvent) });

    entityData = abi.encode(allCAEventData);

    return (changedEntity, entityData);
  }

  function getNutrientConversion(
    bytes32 interactEntity,
    BodySimData memory entitySimData
  ) internal returns (bytes memory) {
    CAEventData[] memory allCAEventData = new CAEventData[](1);
    VoxelCoord memory coord = getCAEntityPositionStrict(IStore(_world()), interactEntity);
    allCAEventData[0] = transfer(
      SimTable.Energy,
      SimTable.Nutrients,
      entitySimData,
      interactEntity,
      coord,
      entitySimData.energy
    );
    return abi.encode(allCAEventData);
  }

  function getNutrientsToSoil(uint256 soilNutrients) internal pure returns (uint256) {
    return soilNutrients / 5; // Transfer 20% of its energy to Soil
  }

  function getNutrientsToPlant(uint256 soilNutrients) internal pure returns (uint256) {
    return soilNutrients / 10; // Transfer 10% of its energy to Seed or Young Plant
  }

  function calculateNumSoilNeighbours(
    address callerAddress,
    bytes32[] memory neighbourEntityIds
  ) internal view returns (uint256 numSoilNeighbours) {
    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }
      // Check if the neighbor is a Soil, Seed, or Young Plant cell
      if (entityIsSoil(callerAddress, neighbourEntityIds[i])) {
        numSoilNeighbours += 1;
      }
    }
    return numSoilNeighbours;
  }

  function getEntityData(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    BodySimData memory entitySimData
  ) internal returns (bytes memory) {
    uint256 transferNutrientsToSoil;
    uint256 transferNutrientsToPlant;
    {
      transferNutrientsToSoil = getNutrientsToSoil(entitySimData.nutrients);
      transferNutrientsToPlant = getNutrientsToPlant(entitySimData.nutrients);
      if (transferNutrientsToSoil == 0 && transferNutrientsToPlant == 0) {
        return new bytes(0);
      }
      // Calculate # of soil neighbours
      uint256 numSoilNeighbours = calculateNumSoilNeighbours(callerAddress, neighbourEntityIds);
      if (numSoilNeighbours > 0) {
        transferNutrientsToSoil = transferNutrientsToSoil / numSoilNeighbours;
        Soil.setLastInteractionBlock(callerAddress, interactEntity, block.number);
      }
    }

    CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length);

    bool hasTransfer = false;
    bool hasPlant = false;

    // Calculate soil neighbours

    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }
      VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);
      // Check if the neighbor is a Soil, Seed, or Young Plant cell
      if (entityIsSoil(callerAddress, neighbourEntityIds[i])) {
        allCAEventData[i] = transfer(
          SimTable.Nutrients,
          SimTable.Nutrients,
          entitySimData,
          neighbourEntityIds[i],
          neighbourCoord,
          transferNutrientsToSoil
        );
        if (transferNutrientsToSoil > 0) {
          hasTransfer = true;
        }
      } else if (isValidPlantNeighbour(callerAddress, neighbourEntityIds[i], neighbourEntityDirections[i])) {
        allCAEventData[i] = transfer(
          SimTable.Nutrients,
          SimTable.Nutrients,
          entitySimData,
          neighbourEntityIds[i],
          neighbourCoord,
          transferNutrientsToPlant
        );
        if (transferNutrientsToPlant > 0) {
          hasTransfer = true;
        }
        hasPlant = true;
      }
    }

    if (hasPlant) {
      Soil.setLastInteractionBlock(callerAddress, interactEntity, block.number);
    }

    // Check if there's at least one transfer
    if (hasTransfer) {
      return abi.encode(allCAEventData);
    }

    return new bytes(0);
  }

  function eventHandlerSoil(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }

  function neighbourEventHandlerSoil(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public returns (bool, bytes memory) {
    return super.neighbourEventHandler(callerAddress, neighbourEntityId, centerEntityId);
  }
}
