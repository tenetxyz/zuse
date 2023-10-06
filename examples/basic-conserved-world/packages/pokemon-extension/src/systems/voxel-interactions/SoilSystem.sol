// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelInteraction } from "@tenet-base-ca/src/prototypes/VoxelInteraction.sol";
import { BlockDirection, BodyPhysicsData, CAEventData, CAEventType, SimEventData, SimTable, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { Plant } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { entityIsSoil, entityIsPlant } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { getVoxelBodyPhysicsFromCaller, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";
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

    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(neighbourEntityId);
    uint256 transferEnergyToSoil = getEnergyToSoil(entityBodyPhysics.energy);
    uint256 transferEnergyToPlant = getEnergyToPlant(entityBodyPhysics.energy);
    if (transferEnergyToSoil == 0 && transferEnergyToPlant == 0) {
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

    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(interactEntity);
    entityData = getEntityData(
      callerAddress,
      interactEntity,
      neighbourEntityIds,
      neighbourEntityDirections,
      entityBodyPhysics
    );

    // Note: we don't need to set changedEntity to true, because we don't need another event

    return (changedEntity, entityData);
  }

  function getEnergyToSoil(uint256 soilEnergy) internal pure returns (uint256) {
    return soilEnergy / 5; // Transfer 20% of its energy to Soil
  }

  function getEnergyToPlant(uint256 soilEnergy) internal pure returns (uint256) {
    return soilEnergy / 10; // Transfer 10% of its energy to Seed or Young Plant
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
    BodyPhysicsData memory entityBodyPhysics
  ) internal returns (bytes memory) {
    uint256 transferEnergyToSoil = getEnergyToSoil(entityBodyPhysics.energy);
    uint256 transferEnergyToPlant = getEnergyToPlant(entityBodyPhysics.energy);
    if (transferEnergyToSoil == 0 && transferEnergyToPlant == 0) {
      return new bytes(0);
    }

    CAEventData[] memory allCAEventData = new CAEventData[](neighbourEntityIds.length);

    // Calculate # of soil neighbours
    uint256 numSoilNeighbours = calculateNumSoilNeighbours(callerAddress, neighbourEntityIds);
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
        uint256 energyTransferAmount = transferEnergyToSoil / numSoilNeighbours;
        allCAEventData[i] = transferEnergy(
          entityBodyPhysics,
          neighbourEntityIds[i],
          neighbourCoord,
          energyTransferAmount
        );
        if (energyTransferAmount > 0) {
          hasTransfer = true;
        }
      } else if (isValidPlantNeighbour(callerAddress, neighbourEntityIds[i], neighbourEntityDirections[i])) {
        allCAEventData[i] = transferEnergy(
          entityBodyPhysics,
          neighbourEntityIds[i],
          neighbourCoord,
          transferEnergyToPlant
        );
        if (transferEnergyToPlant > 0) {
          hasTransfer = true;
        }
        hasPlant = true;
      }
    }

    if (hasPlant || numSoilNeighbours > 0) {
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
