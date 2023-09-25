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
    bool isPlant = entityIsPlant(callerAddress, neighbourEntityId);
    if (isPlant) {
      if (neighbourBlockDirection == BlockDirection.Down) {
        PlantStage plantStage = Plant.getStage(callerAddress, neighbourEntityId);
        isPlant = plantStage == PlantStage.Seed || plantStage == PlantStage.Sprout;
      } else {
        isPlant = false;
      }
    }
    changedEntity = entityIsSoil(callerAddress, neighbourEntityId) || isPlant;
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
    changedEntity = false;
    uint256 lastEnergy = Soil.getLastEnergy(callerAddress, interactEntity);
    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(interactEntity);
    if (lastEnergy == entityBodyPhysics.energy) {
      // No energy change
      return (changedEntity, entityData);
    }
    Soil.setLastEnergy(callerAddress, interactEntity, entityBodyPhysics.energy);
    changedEntity = true;

    uint256 transferEnergyToSoil = entityBodyPhysics.energy / 5; // Transfer 20% of its energy to Soil
    uint256 transferEnergyToPlant = entityBodyPhysics.energy / 10; // Transfer 10% of its energy to Seed or Young Plant

    VoxelCoord[] memory transferCoords = new VoxelCoord[](2);
    uint256[] memory energyFluxAmounts = new uint256[](2);

    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 compareEntity = neighbourEntityIds[i];
      BlockDirection compareBlockDirection = neighbourEntityDirections[i];
      VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), compareEntity);
      // Check if the neighbor is a Soil, Seed, or Young Plant cell
      if (entityIsSoil(callerAddress, compareEntity) && transferEnergyToSoil > 0) {
        // Transfer more energy to neighboring Soil
        if (energyFluxAmounts[0] == 0) {
          transferCoords[0] = neighbourCoord;
          energyFluxAmounts[0] = transferEnergyToSoil;
        } else {
          require(energyFluxAmounts[1] == 0, "Only 2 neighbours can be transferred energy");
          transferCoords[1] = neighbourCoord;
          energyFluxAmounts[1] = transferEnergyToSoil;
        }
      } else if (entityIsPlant(callerAddress, compareEntity) && transferEnergyToPlant > 0) {
        console.log("is plant");
        console.logUint(transferEnergyToPlant);
        console.logBool(compareBlockDirection == BlockDirection.Down);
        console.logBool(compareBlockDirection == BlockDirection.Up);
        console.logUint(uint(compareBlockDirection));
        if (compareBlockDirection == BlockDirection.Down) {
          PlantStage plantStage = Plant.getStage(callerAddress, compareEntity);
          if (plantStage == PlantStage.Seed || plantStage == PlantStage.Sprout) {
            if (energyFluxAmounts[0] == 0) {
              transferCoords[0] = neighbourCoord;
              energyFluxAmounts[0] = transferEnergyToPlant;
            } else {
              require(energyFluxAmounts[1] == 0, "Only 2 neighbours can be transferred energy");
              transferCoords[1] = neighbourCoord;
              energyFluxAmounts[1] = transferEnergyToPlant;
            }
          }
        }
      }
    }

    if (energyFluxAmounts[0] > 0) {
      entityData = abi.encode(
        CAEventData({
          eventType: CAEventType.FluxEnergy,
          newCoords: transferCoords,
          energyFluxAmounts: energyFluxAmounts,
          massFluxAmount: 0
        })
      );
    }

    return (changedEntity, entityData);
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
