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
import { uint256ToInt256, uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { EventType, SoilType } from "@tenet-pokemon-extension/src/codegen/Types.sol";
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
    if (!entitySimData.hasNitrogen || !entitySimData.hasPhosphorous || !entitySimData.hasPotassium) {
      return initSoilProperties(callerAddress, neighbourEntityId, entitySimData);
    }
    if (entitySimData.energy > 0) {
      // We convert all our general energy to nutrient energy
      entityData = getNutrientConversion(callerAddress, neighbourEntityId, entitySimData);
      return (changedEntity, entityData);
    }

    if (Soil.getLastEvent(callerAddress, neighbourEntityId) != EventType.None) {
      Soil.setLastEvent(callerAddress, neighbourEntityId, EventType.None);
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
    if (!entitySimData.hasNitrogen || !entitySimData.hasPhosphorous || !entitySimData.hasPotassium) {
      return initSoilProperties(callerAddress, interactEntity, entitySimData);
    }
    if (entitySimData.energy > 0) {
      // We convert all our general energy to nutrient energy
      entityData = getNutrientConversion(callerAddress, interactEntity, entitySimData);
      return (changedEntity, entityData);
    }

    if (Soil.getLastEvent(callerAddress, interactEntity) != EventType.None) {
      Soil.setLastEvent(callerAddress, interactEntity, EventType.None);
    }

    SoilType soilType = Soil.getSoilType(callerAddress, interactEntity);

    bool hasTransfer = false;

    if (soilType == SoilType.ProteinSoil) {
      (entityData, hasTransfer) = runProteinSoilLogic(
        callerAddress,
        interactEntity,
        neighbourEntityIds,
        neighbourEntityDirections,
        entitySimData
      );
    } else if (soilType == SoilType.ElixirSoil) {
      (entityData, hasTransfer) = runElixirSoilLogic(
        callerAddress,
        interactEntity,
        neighbourEntityIds,
        neighbourEntityDirections,
        entitySimData
      );
    } else if (soilType == SoilType.Concentrative) {
      (entityData, hasTransfer) = runConcentrativeSoilLogic(
        callerAddress,
        interactEntity,
        neighbourEntityIds,
        neighbourEntityDirections,
        entitySimData
      );
    } else if (soilType == SoilType.Diffusive) {
      (entityData, hasTransfer) = runDiffusiveSoilLogic(
        callerAddress,
        interactEntity,
        neighbourEntityIds,
        neighbourEntityDirections,
        entitySimData
      );
    }

    // Check if there's at least one transfer
    if (hasTransfer) {
      Soil.setLastInteractionBlock(callerAddress, interactEntity, block.number);
    }

    // Note: we don't need to set changedEntity to true, because we don't need another event

    return (changedEntity, entityData);
  }

  function initSoilProperties(
    address callerAddress,
    bytes32 interactEntity,
    BodySimData memory entitySimData
  ) internal returns (bool changedEntity, bytes memory entityData) {
    SoilType soilType = Soil.getSoilType(callerAddress, interactEntity);
    EventType lastEventType = Soil.getLastEvent(callerAddress, interactEntity);
    VoxelEntity memory entity = VoxelEntity({ scale: 1, entityId: caEntityToEntity(interactEntity) });
    VoxelCoord memory coord = getCAEntityPositionStrict(IStore(_world()), interactEntity);

    if (lastEventType != EventType.SetNPK) {
      console.log("setNPKSimEvent soil NPK");
      console.logBytes32(interactEntity);
      uint256 numSimEvents = entitySimData.energy > 0 ? 4 : 3;
      SimEventData[] memory allSimEventData = new SimEventData[](numSimEvents);
      uint256 intNitrogen = 0;
      uint256 initPhosphorous = 0;
      uint256 initPotassium = 0;

      if (soilType == SoilType.ProteinSoil) {
        intNitrogen = 100;
      } else if (soilType == SoilType.ElixirSoil) {
        initPhosphorous = 100;
      } else if (soilType == SoilType.Concentrative) {
        intNitrogen = 30;
        initPhosphorous = 30;
        initPotassium = 30;
      } else if (soilType == SoilType.Diffusive) {
        intNitrogen = 30;
        initPhosphorous = 30;
        initPotassium = 30;
      }

      allSimEventData[0] = SimEventData({
        senderTable: SimTable.Nitrogen,
        senderValue: abi.encode(0),
        targetEntity: entity,
        targetCoord: coord,
        targetTable: SimTable.Nitrogen,
        targetValue: abi.encode(intNitrogen)
      });
      allSimEventData[1] = SimEventData({
        senderTable: SimTable.Phosphorous,
        senderValue: abi.encode(0),
        targetEntity: entity,
        targetCoord: coord,
        targetTable: SimTable.Phosphorous,
        targetValue: abi.encode(initPhosphorous)
      });
      allSimEventData[2] = SimEventData({
        senderTable: SimTable.Potassium,
        senderValue: abi.encode(0),
        targetEntity: entity,
        targetCoord: coord,
        targetTable: SimTable.Potassium,
        targetValue: abi.encode(initPotassium)
      });
      if (entitySimData.energy > 0) {
        allSimEventData[3] = SimEventData({
          senderTable: SimTable.Energy,
          senderValue: abi.encode(uint256ToNegativeInt256(entitySimData.energy)),
          targetEntity: entity,
          targetCoord: coord,
          targetTable: SimTable.Nutrients,
          targetValue: abi.encode(uint256ToInt256(entitySimData.energy))
        });
      }

      CAEventData[] memory allCAEventData = new CAEventData[](1);
      allCAEventData[0] = CAEventData({ eventType: CAEventType.BatchSimEvent, eventData: abi.encode(allSimEventData) });
      entityData = abi.encode(allCAEventData);
      Soil.setLastEvent(callerAddress, interactEntity, EventType.SetNPK);
      return (changedEntity, entityData);
    }

    return (changedEntity, entityData);
  }

  function getNutrientConversion(
    address callerAddress,
    bytes32 interactEntity,
    BodySimData memory entitySimData
  ) internal returns (bytes memory) {
    EventType lastEventType = Soil.getLastEvent(callerAddress, interactEntity);

    if (entitySimData.energy > 0 && lastEventType != EventType.SetNutrients) {
      CAEventData[] memory allCAEventData = new CAEventData[](1);
      VoxelCoord memory coord = getCAEntityPositionStrict(IStore(_world()), interactEntity);
      console.log("converting");
      console.logUint(entitySimData.energy);
      allCAEventData[0] = transfer(
        SimTable.Energy,
        SimTable.Nutrients,
        entitySimData,
        interactEntity,
        coord,
        entitySimData.energy
      );
      Soil.setLastEvent(callerAddress, interactEntity, EventType.SetNutrients);
      return abi.encode(allCAEventData);
    }

    return new bytes(0);
  }

  function entityHasNPK(bytes32 interactEntity) internal returns (bool) {
    BodySimData memory entitySimData = getEntitySimData(interactEntity);
    return entitySimData.nitrogen > 0 && entitySimData.phosphorous > 0 && entitySimData.potassium > 0;
  }

  function runConcentrativeSoilLogic(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    BodySimData memory entitySimData
  ) internal returns (bytes memory, bool) {
    // Calculate # of soil neighbours

    CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length);

    bool hasTransfer = false;

    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }
      VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);
      // Check if the neighbor is a Soil, Seed, or Young Plant cell
      if (entityIsSoil(callerAddress, neighbourEntityIds[i]) && entityHasNPK(neighbourEntityIds[i])) {
        BodySimData memory neighbourEntitySimData = getEntitySimData(neighbourEntityIds[i]);
        if (entitySimData.nutrients < neighbourEntitySimData.nutrients) {
          uint256 amountToTransfer = entitySimData.nutrients / 10; // 10%
          allCAEventData[i] = transfer(
            SimTable.Nutrients,
            SimTable.Nutrients,
            entitySimData,
            neighbourEntityIds[i],
            neighbourCoord,
            amountToTransfer
          );
          entitySimData.nutrients -= amountToTransfer;
        }
        hasTransfer = true;
      } else if (
        isValidPlantNeighbour(callerAddress, neighbourEntityIds[i], neighbourEntityDirections[i]) &&
        entityHasNPK(neighbourEntityIds[i])
      ) {
        if (entitySimData.nutrients / 2 > 0) {
          uint256 convertNutrientsToElixir = entitySimData.nutrients / 2; // Convert all nutrients to protein
          uint256 convertNutrientsToProtein = entitySimData.nutrients / 2; // Convert all nutrients to protein
          SimEventData[] memory foodSimEventData = new SimEventData[](2);
          VoxelEntity memory targetEntity = VoxelEntity({
            scale: 1,
            entityId: caEntityToEntity(neighbourEntityIds[i])
          });
          foodSimEventData[0] = SimEventData({
            senderTable: SimTable.Nutrients,
            senderValue: abi.encode(uint256ToNegativeInt256(convertNutrientsToElixir)),
            targetEntity: targetEntity,
            targetCoord: neighbourCoord,
            targetTable: SimTable.Elixir,
            targetValue: abi.encode(uint256ToInt256(convertNutrientsToElixir))
          });
          foodSimEventData[1] = SimEventData({
            senderTable: SimTable.Nutrients,
            senderValue: abi.encode(uint256ToNegativeInt256(convertNutrientsToProtein)),
            targetEntity: targetEntity,
            targetCoord: neighbourCoord,
            targetTable: SimTable.Protein,
            targetValue: abi.encode(uint256ToInt256(convertNutrientsToProtein))
          });
          allCAEventData[i] = CAEventData({
            eventType: CAEventType.BatchSimEvent,
            eventData: abi.encode(foodSimEventData)
          });
          entitySimData.nutrients -= convertNutrientsToElixir + convertNutrientsToProtein;
        }
        hasTransfer = true;
      }
    }

    return (abi.encode(allCAEventData), hasTransfer);
  }

  function runDiffusiveSoilLogic(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    BodySimData memory entitySimData
  ) internal returns (bytes memory, bool) {
    CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length);

    bool hasTransfer = false;

    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }
      VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);
      // Check if the neighbor is a Soil, Seed, or Young Plant cell
      if (entityIsSoil(callerAddress, neighbourEntityIds[i]) && entityHasNPK(neighbourEntityIds[i])) {
        BodySimData memory neighbourEntitySimData = getEntitySimData(neighbourEntityIds[i]);
        if (entitySimData.nutrients > neighbourEntitySimData.nutrients) {
          uint256 amountToTransfer = entitySimData.nutrients / 10; // 10%
          allCAEventData[i] = transfer(
            SimTable.Nutrients,
            SimTable.Nutrients,
            entitySimData,
            neighbourEntityIds[i],
            neighbourCoord,
            amountToTransfer
          );
          entitySimData.nutrients -= amountToTransfer;
        }
        hasTransfer = true;
      } else if (
        isValidPlantNeighbour(callerAddress, neighbourEntityIds[i], neighbourEntityDirections[i]) &&
        entityHasNPK(neighbourEntityIds[i])
      ) {
        if (entitySimData.nutrients / 2 > 0) {
          uint256 convertNutrientsToElixir = entitySimData.nutrients / 2; // Convert all nutrients to protein
          uint256 convertNutrientsToProtein = entitySimData.nutrients / 2; // Convert all nutrients to protein
          SimEventData[] memory foodSimEventData = new SimEventData[](2);
          VoxelEntity memory targetEntity = VoxelEntity({
            scale: 1,
            entityId: caEntityToEntity(neighbourEntityIds[i])
          });
          foodSimEventData[0] = SimEventData({
            senderTable: SimTable.Nutrients,
            senderValue: abi.encode(uint256ToNegativeInt256(convertNutrientsToElixir)),
            targetEntity: targetEntity,
            targetCoord: neighbourCoord,
            targetTable: SimTable.Elixir,
            targetValue: abi.encode(uint256ToInt256(convertNutrientsToElixir))
          });
          foodSimEventData[1] = SimEventData({
            senderTable: SimTable.Nutrients,
            senderValue: abi.encode(uint256ToNegativeInt256(convertNutrientsToProtein)),
            targetEntity: targetEntity,
            targetCoord: neighbourCoord,
            targetTable: SimTable.Protein,
            targetValue: abi.encode(uint256ToInt256(convertNutrientsToProtein))
          });
          allCAEventData[i] = CAEventData({
            eventType: CAEventType.BatchSimEvent,
            eventData: abi.encode(foodSimEventData)
          });
          entitySimData.nutrients -= convertNutrientsToElixir + convertNutrientsToProtein;
        }
        hasTransfer = true;
      }
    }

    return (abi.encode(allCAEventData), hasTransfer);
  }

  function runProteinSoilLogic(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    BodySimData memory entitySimData
  ) internal returns (bytes memory, bool) {
    CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length);

    bool hasTransfer = false;

    // Calculate soil neighbours
    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }
      VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);
      if (
        isValidPlantNeighbour(callerAddress, neighbourEntityIds[i], neighbourEntityDirections[i]) &&
        entityHasNPK(neighbourEntityIds[i])
      ) {
        uint256 convertNutrientsToProtein = entitySimData.nutrients; // Convert all nutrients to protein
        if (convertNutrientsToProtein > 0) {
          allCAEventData[i] = transfer(
            SimTable.Nutrients,
            SimTable.Protein,
            entitySimData,
            neighbourEntityIds[i],
            neighbourCoord,
            convertNutrientsToProtein
          );
        }
        hasTransfer = true;
      } else if (entityIsSoil(callerAddress, neighbourEntityIds[i])) {
        BodySimData memory neighbourEntitySimData = getEntitySimData(neighbourEntityIds[i]);
        if (entitySimData.phosphorous > 0 && neighbourEntitySimData.phosphorous < entitySimData.phosphorous) {
          allCAEventData[i] = transfer(
            SimTable.Phosphorous,
            SimTable.Phosphorous,
            entitySimData,
            neighbourEntityIds[i],
            neighbourCoord,
            entitySimData.phosphorous
          );
          entitySimData.phosphorous = 0;
        }
        hasTransfer = true;
      }
    }

    return (abi.encode(allCAEventData), hasTransfer);
  }

  function runElixirSoilLogic(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    BodySimData memory entitySimData
  ) internal returns (bytes memory, bool) {
    CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length);

    bool hasTransfer = false;

    // Calculate soil neighbours
    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }
      VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);
      if (
        isValidPlantNeighbour(callerAddress, neighbourEntityIds[i], neighbourEntityDirections[i]) &&
        entityHasNPK(neighbourEntityIds[i])
      ) {
        uint256 convertNutrientsToElixir = entitySimData.nutrients; // Convert all nutrients to protein
        if (convertNutrientsToElixir > 0) {
          allCAEventData[i] = transfer(
            SimTable.Nutrients,
            SimTable.Elixir,
            entitySimData,
            neighbourEntityIds[i],
            neighbourCoord,
            convertNutrientsToElixir
          );
        }
        hasTransfer = true;
      } else if (entityIsSoil(callerAddress, neighbourEntityIds[i])) {
        BodySimData memory neighbourEntitySimData = getEntitySimData(neighbourEntityIds[i]);
        if (entitySimData.nitrogen > 0 && neighbourEntitySimData.nitrogen < entitySimData.nitrogen) {
          allCAEventData[i] = transfer(
            SimTable.Nitrogen,
            SimTable.Nitrogen,
            entitySimData,
            neighbourEntityIds[i],
            neighbourCoord,
            entitySimData.nitrogen
          );
          entitySimData.nitrogen = 0;
        }
        hasTransfer = true;
      }
    }

    return (abi.encode(allCAEventData), hasTransfer);
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
