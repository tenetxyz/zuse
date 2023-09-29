// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity, EntityEventData, CAEventData, CAEventType } from "@tenet-utils/src/Types.sol";
import { VoxelType, BodyPhysics, WorldConfig } from "@tenet-world/src/codegen/Tables.sol";
import { getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";
import { console } from "forge-std/console.sol";

contract CAEventsSystem is System {
  function caEventsHandler(EntityEventData[] memory entitiesEventData) public {
    for (uint256 i; i < entitiesEventData.length; i++) {
      EntityEventData memory entityEventData = entitiesEventData[i];
      if (entityEventData.eventData.length > 0) {
        // process event
        CAEventData memory worldEventData = abi.decode(entityEventData.eventData, (CAEventData));
        VoxelEntity memory entity = entityEventData.entity;
        VoxelCoord memory entityCoord = getVoxelCoordStrict(entity);
        bytes32 voxelTypeId = VoxelType.getVoxelTypeId(entity.scale, entity.entityId);
        address caAddress = WorldConfig.get(voxelTypeId);
        if (worldEventData.eventType == CAEventType.Move) {
          require(worldEventData.newCoords.length == 1, "newCoords must be length 1");
          IWorld(_world()).moveWithAgent(voxelTypeId, entityCoord, worldEventData.newCoords[0], entity);
        } else if (worldEventData.eventType == CAEventType.FluxEnergy) {
          require(
            worldEventData.energyFluxAmounts.length == worldEventData.newCoords.length,
            "energyFluxAmounts must be same length as newCoords"
          );
          IWorld(_world()).fluxEnergyOut(
            voxelTypeId,
            entityCoord,
            worldEventData.energyFluxAmounts,
            worldEventData.newCoords
          );
        } else if (worldEventData.eventType == CAEventType.FluxMass) {
          IWorld(_world()).fluxMass(voxelTypeId, entityCoord, worldEventData.massFluxAmount);
        } else if (worldEventData.eventType == CAEventType.FluxEnergyAndMass) {
          console.log("FluxEnergyAndMass");
          IWorld(_world()).fluxMass(voxelTypeId, entityCoord, worldEventData.massFluxAmount);
          console.log("fluxing energy now");
          uint256 currentEnergy = BodyPhysics.getEnergy(entity.scale, entity.entityId);
          require(worldEventData.energyFluxAmounts.length == 1, "energyFluxAmounts must be length 1");
          uint256 energyToFlux = worldEventData.energyFluxAmounts[0];
          require(currentEnergy >= energyToFlux, "Not enough energy to flux");
          IWorld(_world()).fluxEnergy(false, caAddress, entity, energyToFlux);
          BodyPhysics.setEnergy(entity.scale, entity.entityId, currentEnergy - energyToFlux);
        }
      }
    }
  }
}
