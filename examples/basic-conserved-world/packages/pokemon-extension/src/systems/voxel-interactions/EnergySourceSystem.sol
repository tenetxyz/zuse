// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelInteraction } from "@tenet-base-ca/src/prototypes/VoxelInteraction.sol";
import { BlockDirection, BodyPhysicsData, CAEventData, CAEventType, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { EnergySource } from "@tenet-pokemon-extension/src/codegen/tables/EnergySource.sol";
import { entityIsEnergySource, entityIsSoil } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { getCAEntityAtCoord, getCAVoxelType, getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";
import { getVoxelBodyPhysicsFromCaller, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";
import { console } from "forge-std/console.sol";

uint256 constant ENERGY_SOURCE_WAIT_BLOCKS = 50;

contract EnergySourceSystem is VoxelInteraction {
  function getEnergyToSoil(uint256 energySourceEnergy) internal pure returns (uint256) {
    return energySourceEnergy / 10; // Emit 10% of its energy
  }

  function onNewNeighbour(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId,
    BlockDirection centerBlockDirection
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    uint256 lastInteractionBlock = EnergySource.getLastInteractionBlock(callerAddress, neighbourEntityId);
    if (block.number <= lastInteractionBlock + ENERGY_SOURCE_WAIT_BLOCKS) {
      console.log("skip energy source");
      return (changedEntity, entityData);
    }

    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(neighbourEntityId);
    uint256 emittedEnergy = getEnergyToSoil(entityBodyPhysics.energy);
    if (emittedEnergy == 0) {
      return (changedEntity, entityData);
    }

    if (!entityIsSoil(callerAddress, centerEntityId)) {
      return (changedEntity, entityData);
    }

    console.log("on new neighbour goo");

    // If we have a soil neighbour and we have energy, then we can transfer energy
    changedEntity = true;

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
    uint256 lastInteractionBlock = EnergySource.getLastInteractionBlock(callerAddress, interactEntity);
    if (block.number <= lastInteractionBlock + ENERGY_SOURCE_WAIT_BLOCKS) {
      return (changedEntity, entityData);
    }

    BodyPhysicsData memory entityBodyPhysics = getVoxelBodyPhysicsFromCaller(interactEntity);
    uint256 emittedEnergy = getEnergyToSoil(entityBodyPhysics.energy);
    if (emittedEnergy == 0) {
      return (changedEntity, entityData);
    }

    console.log("run interaction energy source");

    CAEventData memory transferData = CAEventData({
      eventType: CAEventType.FluxEnergy,
      newCoords: new VoxelCoord[](neighbourEntityIds.length),
      energyFluxAmounts: new uint256[](neighbourEntityIds.length),
      massFluxAmount: 0
    });

    // Calculate # of soil neighbours
    uint256 numSoilNeighbours = 0;
    bool hasTransfer = false;

    for (uint i = 0; i < neighbourEntityIds.length; i++) {
      if (uint256(neighbourEntityIds[i]) == 0) {
        continue;
      }

      if (entityIsSoil(callerAddress, neighbourEntityIds[i])) {
        numSoilNeighbours++;
        VoxelCoord memory neighbourCoord = getCAEntityPositionStrict(IStore(_world()), neighbourEntityIds[i]);
        transferData.newCoords[i] = neighbourCoord;
        transferData.energyFluxAmounts[i] = 1;
      }
    }

    for (uint i = 0; i < transferData.newCoords.length; i++) {
      if (transferData.energyFluxAmounts[i] == 1) {
        transferData.energyFluxAmounts[i] = emittedEnergy / numSoilNeighbours;
        if (transferData.energyFluxAmounts[i] > 0) {
          hasTransfer = true;
        }
      }
    }

    // Check if there's at least one transfer
    if (hasTransfer) {
      entityData = abi.encode(transferData);
    }
    if (numSoilNeighbours > 0) {
      EnergySource.setLastInteractionBlock(callerAddress, interactEntity, block.number);
    }
    // Note: we don't need to set changedEntity to true, because we don't need another event

    return (changedEntity, entityData);
  }

  function eventHandlerEnergySource(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }

  function neighbourEventHandlerEnergySource(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public returns (bool, bytes memory) {
    return super.neighbourEventHandler(callerAddress, neighbourEntityId, centerEntityId);
  }
}
