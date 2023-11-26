// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity, EntityActionData } from "@tenet-utils/src/Types.sol";
import { VoxelType, WorldConfig } from "@tenet-world/src/codegen/Tables.sol";
import { getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";

contract ActionSystem is System {
  function actionsHandler(EntityActionData[] memory entitiesEventData) public {
    // TODO: Optimize the length of this array
    EntityEventData[] memory allNewEntitiesEventData = new EntityEventData[](MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH);
    uint allNewEntitiesEventDataIdx = 0;

    for (uint256 i; i < entitiesEventData.length; i++) {
      EntityEventData memory entityEventData = entitiesEventData[i];
      if (entityEventData.eventData.length == 0) {
        // no event
        continue;
      }

      // process event
      console.log("process events");
      CAEventData[] memory allCAEventData;
      try this.decodeToCAEventDataArray(entityEventData.eventData) returns (CAEventData[] memory decodedValue) {
        allCAEventData = decodedValue;
      } catch {
        continue;
      }
      VoxelEntity memory entity = entityEventData.entity;
      VoxelCoord memory entityCoord = getVoxelCoordStrict(entity);
      for (uint j; j < allCAEventData.length; j++) {
        CAEventData memory caEventData = allCAEventData[j];
        if (caEventData.eventType == CAEventType.None) {
          continue;
        }

        if (caEventData.eventType == CAEventType.SimEvent || caEventData.eventType == CAEventType.BatchSimEvent) {
          SimEventData[] memory allSimEventData;
          if (caEventData.eventType == CAEventType.BatchSimEvent) {
            try this.decodeToSimEventDataArray(caEventData.eventData) returns (SimEventData[] memory decodedValue) {
              allSimEventData = decodedValue;
            } catch {
              continue;
            }
            if (allSimEventData.length == 0) {
              continue;
            }
          } else {
            allSimEventData = new SimEventData[](1);
            try this.decodeToSimEventData(caEventData.eventData) returns (SimEventData memory decodedValue) {
              allSimEventData[0] = decodedValue;
            } catch {
              continue;
            }
          }

          bool calledWorldEvent = false;
          for (uint k = 0; k < allSimEventData.length; k++) {
            SimEventData memory simEventData = allSimEventData[k];
            if (simEventData.senderTable == SimTable.None || simEventData.targetTable == SimTable.None) {
              continue;
            }

            {
              bytes32 targetEntityId = getEntityAtCoord(entity.scale, simEventData.targetCoord);
              if (simEventData.targetEntity.scale == 0 && simEventData.targetEntity.entityId == 0) {
                // then we need to fill it in
                simEventData.targetEntity = VoxelEntity({ scale: entity.scale, entityId: targetEntityId });
              }
              require(simEventData.targetEntity.entityId == targetEntityId, "Entity mismatch");
            }
            require(
              distanceBetween(entityCoord, simEventData.targetCoord) <= 1,
              "Target can only be a surrounding neighbour or yourself"
            );
            console.log("setting sim value");
            console.logUint(uint(simEventData.senderTable));
            console.logUint(uint(simEventData.targetTable));
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

            if (simEventData.targetTable == SimTable.Mass) {
              uint256 newMass = Mass.get(
                IStore(SIMULATOR_ADDRESS),
                _world(),
                simEventData.targetEntity.scale,
                simEventData.targetEntity.entityId
              );
              if (newMass == 0) {
                bytes32 voxelTypeId = VoxelType.getVoxelTypeId(
                  simEventData.targetEntity.scale,
                  simEventData.targetEntity.entityId
                );
                IWorld(_world()).mineWithAgent(voxelTypeId, simEventData.targetCoord, simEventData.targetEntity);
                calledWorldEvent = true;
              }
            }
          }

          if (!calledWorldEvent) {
            // In a batch, we only run the first target entity
            SimEventData memory simEventData = allSimEventData[0];
            if (simEventData.targetEntity.scale == 0 && simEventData.targetEntity.entityId == 0) {
              continue;
            }

            console.log("running ca");
            address caAddress = WorldConfig.get(
              VoxelType.getVoxelTypeId(simEventData.targetEntity.scale, simEventData.targetEntity.entityId)
            );
            EntityEventData[] memory newEntitiesEventData = IWorld(_world()).runCA(
              caAddress,
              simEventData.targetEntity,
              bytes4(0)
            );
            for (uint l = 0; l < newEntitiesEventData.length; l++) {
              if (newEntitiesEventData[l].eventData.length > 0) {
                console.log("new event from post run sim event");
                allNewEntitiesEventData[allNewEntitiesEventDataIdx] = newEntitiesEventData[l];
                allNewEntitiesEventDataIdx++;
                require(allNewEntitiesEventDataIdx < MAX_VOXEL_NEIGHBOUR_UPDATE_DEPTH, "Too many new entities");
              }
            }

            // We know both the sender and receiver will have changed, thus we update both their variants
            IWorld(_world()).updateVariant(caAddress, entity);
            IWorld(_world()).updateVariant(caAddress, simEventData.targetEntity);
          }
        } else if (caEventData.eventType == CAEventType.WorldEvent) {
          WorldEventData memory worldEventData;
          try this.decodeToWorldEventData(caEventData.eventData) returns (WorldEventData memory decodedValue) {
            worldEventData = decodedValue;
          } catch {
            continue;
          }
          if (worldEventData.eventType == WorldEventType.Move) {
            bytes32 voxelTypeId = VoxelType.getVoxelTypeId(entity.scale, entity.entityId);
            IWorld(_world()).moveWithAgent(voxelTypeId, entityCoord, worldEventData.newCoord, entity);
          }
        }
      }
    }

    if (allNewEntitiesEventDataIdx > 0) {
      actionsHandler(allNewEntitiesEventData);
    }
  }
}
