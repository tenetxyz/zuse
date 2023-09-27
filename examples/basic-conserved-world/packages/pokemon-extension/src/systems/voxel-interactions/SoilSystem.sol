// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelInteraction } from "@tenet-base-ca/src/prototypes/VoxelInteraction.sol";
import { BlockDirection, BodyPhysicsData, CAEventData, CAEventType, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { EnergySource } from "@tenet-pokemon-extension/src/codegen/tables/EnergySource.sol";
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { Plant } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { PlantStage } from "@tenet-pokemon-extension/src/codegen/Types.sol";
import { entityIsEnergySource, entityIsSoil, entityIsPlant } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { getVoxelBodyPhysicsFromCaller, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract SoilSystem is VoxelInteraction {
  function onNewNeighbour(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    uint256 lastInteractionBlock = Soil.getLastInteractionBlock(callerAddress, interactEntity);
    if (block.number == lastInteractionBlock) {
      console.log("skip new neighbour soil");
      return (changedEntity, entityData);
    }

    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(interactEntity);
    uint256 transferEnergyToSoil = getEnergyToSoil(entityBodyPhysics.energy);
    uint256 transferEnergyToPlant = getEnergyToPlant(entityBodyPhysics.energy);
    if (transferEnergyToSoil == 0 && transferEnergyToPlant == 0) {
      return (changedEntity, entityData);
    }

    if (
      !entityIsSoil(callerAddress, neighbourEntityId) &&
      !isValidPlantNeighbour(callerAddress, neighbourEntityId, neighbourBlockDirection)
    ) {
      return (changedEntity, entityData);
    }

    console.log("on new neighbour go soil");
    console.logBytes32(interactEntity);

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
      console.log("skip interaction soil");
      return (changedEntity, entityData);
    }

    console.log("run interaction soil");
    console.logBytes32(interactEntity);

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

  function getEnergyToSoil(uint256 energySourceEnergy) internal pure returns (uint256) {
    return energySourceEnergy / 5; // Transfer 20% of its energy to Soil
  }

  function getEnergyToPlant(uint256 energySourceEnergy) internal pure returns (uint256) {
    return energySourceEnergy / 10; // Transfer 10% of its energy to Seed or Young Plant
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
      console.log("skip no energy");
      return new bytes(0);
    }

    CAEventData memory transferData = CAEventData({
      eventType: CAEventType.FluxEnergy,
      newCoords: new VoxelCoord[](neighbourEntityIds.length),
      energyFluxAmounts: new uint256[](neighbourEntityIds.length),
      massFluxAmount: 0
    });

    // Calculate # of soil neighbours
    uint256 numSoilNeighbours = 0;
    bool hasTransfer = false;
    uint plantIdx = 0;
    bool hasPlant = false;

    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }
      VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);
      // Check if the neighbor is a Soil, Seed, or Young Plant cell
      if (entityIsSoil(callerAddress, neighbourEntityIds[i])) {
        numSoilNeighbours += 1;
        transferData.newCoords[i] = neighbourCoord;
        transferData.energyFluxAmounts[i] = 1;
      } else if (isValidPlantNeighbour(callerAddress, neighbourEntityIds[i], neighbourEntityDirections[i])) {
        transferData.newCoords[i] = neighbourCoord;
        transferData.energyFluxAmounts[i] = transferEnergyToPlant;
        plantIdx = i;
        hasPlant = true;
      }
    }

    for (uint i = 0; i < transferData.newCoords.length; i++) {
      if (hasPlant && i == plantIdx) {
        if (transferData.energyFluxAmounts[i] > 0) {
          hasTransfer = true;
        }
        continue;
      }
      if (transferData.energyFluxAmounts[i] == 1) {
        transferData.energyFluxAmounts[i] = transferEnergyToSoil / numSoilNeighbours;
        if (transferData.energyFluxAmounts[i] > 0) {
          hasTransfer = true;
        }
      }
    }

    // Check if there's at least one transfer
    if (hasTransfer) {
      console.log("transferring");
      return abi.encode(transferData);
    }
    if (hasPlant || numSoilNeighbours > 0) {
      console.log("set last interaction block");
      Soil.setLastInteractionBlock(callerAddress, interactEntity, block.number);
    }

    return new bytes(0);
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    return entityIsSoil(callerAddress, entityId);
  }

  function eventHandlerSoil(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory, bytes[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
