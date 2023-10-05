// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity, EntityEventData, SimEventData, SimTable } from "@tenet-utils/src/Types.sol";
import { VoxelType, WorldConfig } from "@tenet-world/src/codegen/Tables.sol";
import { getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { console } from "forge-std/console.sol";
import { getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";
import { setSimValue } from "@tenet-simulator/src/CallUtils.sol";

contract CAEventsSystem is System {
  function caEventsHandler(EntityEventData[] memory entitiesEventData) public {
    for (uint256 i; i < entitiesEventData.length; i++) {
      EntityEventData memory entityEventData = entitiesEventData[i];
      if (entityEventData.eventData.length == 0) {
        // no event
        continue;
      }

      // process event
      SimEventData[] memory allSimEventData = abi.decode(entityEventData.eventData, (SimEventData[]));
      VoxelEntity memory entity = entityEventData.entity;
      VoxelCoord memory entityCoord = getVoxelCoordStrict(entity);
      // bytes32 voxelTypeId = VoxelType.getVoxelTypeId(entity.scale, entity.entityId);
      for (uint j; j < allSimEventData.length; j++) {
        SimEventData memory simEventData = allSimEventData[j];
        if (simEventData.table == SimTable.None) {
          continue;
        }
        if (simEventData.targetEntity.scale == 0 && simEventData.targetEntity.entityId == 0) {
          // then we need to fill it in
          bytes32 targetEntityId = getEntityAtCoord(entity.scale, simEventData.targetCoord);
          simEventData.targetEntity = VoxelEntity({ scale: entity.scale, entityId: targetEntityId });
        }
        setSimValue(
          SIMULATOR_ADDRESS,
          simEventData.table,
          entity,
          entityCoord,
          simEventData.senderValue,
          simEventData.targetEntity,
          simEventData.targetCoord,
          simEventData.targetValue
        );
      }

      // if (worldEventData.eventType == CAEventType.Move) {
      //   require(worldEventData.newCoords.length == 1, "newCoords must be length 1");
      //   IWorld(_world()).moveWithAgent(voxelTypeId, entityCoord, worldEventData.newCoords[0], entity);
      // } else if (worldEventData.eventType == CAEventType.FluxEnergy) {
      //   require(
      //     worldEventData.energyFluxAmounts.length == worldEventData.newCoords.length,
      //     "energyFluxAmounts must be same length as newCoords"
      //   );
      //   IWorld(_world()).fluxEnergyOut(
      //     voxelTypeId,
      //     entityCoord,
      //     worldEventData.energyFluxAmounts,
      //     worldEventData.newCoords
      //   );
      // } else if (worldEventData.eventType == CAEventType.FluxMass) {
      //   IWorld(_world()).fluxMass(voxelTypeId, entityCoord, worldEventData.massFluxAmount);
      // } else if (worldEventData.eventType == CAEventType.FluxEnergyAndMass) {
      //   IWorld(_world()).fluxMass(voxelTypeId, entityCoord, worldEventData.massFluxAmount);
      //   require(worldEventData.energyFluxAmounts.length == 1, "energyFluxAmounts must be length 1");
      //   fluxEnergyOut(SIMULATOR_ADDRESS, entity, worldEventData.energyFluxAmounts[0]);
      // }
    }
  }
}
