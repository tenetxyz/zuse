// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, VoxelEntity, EntityEventData, CAEventData, CAEventType } from "@tenet-utils/src/Types.sol";
import { VoxelType } from "@tenet-world/src/codegen/Tables.sol";
import { getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";

contract CAEventsSystem is System {
  function caEventsHandler(EntityEventData[] memory entitiesEventData) public {
    for (uint256 i; i < entitiesEventData.length; i++) {
      EntityEventData memory entityEventData = entitiesEventData[i];
      if (entityEventData.eventData.length > 0) {
        // process event
        CAEventData memory worldEventData = abi.decode(entityEventData.eventData, (CAEventData));
        if (worldEventData.eventType == CAEventType.Move) {
          VoxelEntity memory entity = entityEventData.entity;
          VoxelCoord memory oldCoord = getVoxelCoordStrict(entity);
          bytes32 voxelTypeId = VoxelType.getVoxelTypeId(entity.scale, entity.entityId);
          IWorld(_world()).moveWithAgent(voxelTypeId, oldCoord, worldEventData.newCoord, entity);
        }
      }
    }
  }
}
