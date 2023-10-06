// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity, EntityEventData, CAEventData, CAEventType, WorldEventType, WorldEventData, SimEventData, SimTable } from "@tenet-utils/src/Types.sol";
import { VoxelType, WorldConfig } from "@tenet-world/src/codegen/Tables.sol";
import { getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { console } from "forge-std/console.sol";
import { getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";
import { setSimValue } from "@tenet-simulator/src/CallUtils.sol";
import { MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH } from "@tenet-utils/src/Constants.sol";

contract CAEventsSystem is System {
  function caEventsHandler(EntityEventData[] memory entitiesEventData) public {
    // TODO: Optimize the length of this array
    EntityEventData[] memory allNewEntitiesEventData = new EntityEventData[](MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH);
    uint allNewEntitiesEventDataIdx = 0;
    VoxelEntity[] memory entitiesToRunCA = new VoxelEntity[](MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH);
    uint entitiesToRunCAIdx = 0;

    for (uint256 i; i < entitiesEventData.length; i++) {
      EntityEventData memory entityEventData = entitiesEventData[i];
      if (entityEventData.eventData.length == 0) {
        // no event
        continue;
      }

      // process event
      console.log("process events");
      CAEventData[] memory allCAEventData = abi.decode(entityEventData.eventData, (CAEventData[]));
      VoxelEntity memory entity = entityEventData.entity;
      VoxelCoord memory entityCoord = getVoxelCoordStrict(entity);
      for (uint j; j < allCAEventData.length; j++) {
        CAEventData memory caEventData = allCAEventData[j];
        if (caEventData.eventType == CAEventType.None) {
          continue;
        }

        if (caEventData.eventType == CAEventType.SimEvent) {
          SimEventData memory simEventData = abi.decode(caEventData.eventData, (SimEventData));
          if (simEventData.senderTable == SimTable.None || simEventData.targetTable == SimTable.None) {
            continue;
          }

          if (simEventData.targetEntity.scale == 0 && simEventData.targetEntity.entityId == 0) {
            // then we need to fill it in
            bytes32 targetEntityId = getEntityAtCoord(entity.scale, simEventData.targetCoord);
            simEventData.targetEntity = VoxelEntity({ scale: entity.scale, entityId: targetEntityId });
          }
          console.log("setting sim value");
          setSimValue(
            SIMULATOR_ADDRESS,
            entity,
            entityCoord,
            simEventData.senderTable,
            simEventData.senderValue,
            simEventData.targetEntity,
            simEventData.targetCoord,
            simEventData.targetTable,
            simEventData.targetValue
          );

          bool calledWorldEvent = false;
          if (simEventData.targetTable == SimTable.Mass) {
            uint256 newMass = abi.decode(simEventData.targetValue, (uint256));
            if (newMass == 0) {
              bytes32 voxelTypeId = VoxelType.getVoxelTypeId(
                simEventData.targetEntity.scale,
                simEventData.targetEntity.entityId
              );
              IWorld(_world()).mineWithAgent(voxelTypeId, simEventData.targetCoord, simEventData.targetEntity);
              calledWorldEvent = true;
            }
          }

          if (!calledWorldEvent) {
            entitiesToRunCA[entitiesToRunCAIdx] = simEventData.targetEntity;
            entitiesToRunCAIdx++;
            require(entitiesToRunCAIdx < MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH, "Too many entities to run CA");
          }
        } else if (caEventData.eventType == CAEventType.WorldEvent) {
          WorldEventData memory worldEventData = abi.decode(caEventData.eventData, (WorldEventData));
          if (worldEventData.eventType == WorldEventType.Move) {
            bytes32 voxelTypeId = VoxelType.getVoxelTypeId(entity.scale, entity.entityId);
            IWorld(_world()).moveWithAgent(voxelTypeId, entityCoord, worldEventData.newCoord, entity);
          }
        }
      }
    }

    // Run all the CA's
    for (uint i; i < entitiesToRunCA.length; i++) {
      VoxelEntity memory entity = entitiesToRunCA[i];
      if (entity.scale == 0 && entity.entityId == 0) {
        continue;
      }
      bytes32 voxelTypeId = VoxelType.getVoxelTypeId(entity.scale, entity.entityId);
      address caAddress = WorldConfig.get(voxelTypeId);
      console.log("running ca");
      EntityEventData[] memory newEntitiesEventData = IWorld(_world()).runCA(caAddress, entity, bytes4(0));
      for (uint j = 0; j < newEntitiesEventData.length; j++) {
        if (newEntitiesEventData[j].eventData.length > 0) {
          allNewEntitiesEventData[allNewEntitiesEventDataIdx] = newEntitiesEventData[j];
          allNewEntitiesEventDataIdx++;
          require(allNewEntitiesEventDataIdx < MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH, "Too many new entities");
        }
      }
    }
    if (allNewEntitiesEventDataIdx > 0) {
      console.log("recurse");
      caEventsHandler(allNewEntitiesEventData);
    }
  }
}
