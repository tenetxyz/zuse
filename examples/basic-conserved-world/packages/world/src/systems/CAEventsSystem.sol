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
          IWorld(_world()).moveWithAgent(voxelTypeId, entityCoord, worldEventData.newCoord, entity);
        } else if (worldEventData.eventType == CAEventType.FluxEnergy) {
          console.log("flux out");
          console.logUint(worldEventData.energyFluxAmount);
          IWorld(_world()).fluxEnergyOut(
            voxelTypeId,
            entityCoord,
            worldEventData.energyFluxAmount,
            worldEventData.newCoord
          );
        } else if (worldEventData.eventType == CAEventType.FluxMass) {
          IWorld(_world()).fluxMass(voxelTypeId, entityCoord, worldEventData.massFluxAmount);
        } else if (worldEventData.eventType == CAEventType.FluxEnergyAndMass) {
          IWorld(_world()).fluxMass(voxelTypeId, entityCoord, worldEventData.massFluxAmount);
          uint256 currentEnergy = BodyPhysics.getEnergy(entity.scale, entity.entityId);
          require(currentEnergy >= worldEventData.energyFluxAmount, "Not enough energy to flux");
          IWorld(_world()).fluxEnergy(false, caAddress, entity, worldEventData.energyFluxAmount);
          BodyPhysics.setEnergy(entity.scale, entity.entityId, currentEnergy - worldEventData.energyFluxAmount);
        }
      }
    }
  }
}
