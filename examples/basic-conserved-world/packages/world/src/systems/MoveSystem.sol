// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { MoveEvent } from "@tenet-base-world/src/prototypes/MoveEvent.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, VoxelEntity, EntityEventData } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { MoveEventData } from "@tenet-base-world/src/Types.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { OwnedBy, OwnedByTableId, WorldConfig } from "@tenet-world/src/codegen/Tables.sol";
import { getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";
import { MoveWorldEventData } from "@tenet-world/src/Types.sol";
import { onMove } from "@tenet-simulator/src/CallUtils.sol";
import { console } from "forge-std/console.sol";

contract MoveSystem is MoveEvent {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function processCAEvents(EntityEventData[] memory entitiesEventData) internal override {
    IWorld(_world()).caEventsHandler(entitiesEventData);
  }

  // Called by users
  function moveWithAgent(
    bytes32 voxelTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    VoxelEntity memory agentEntity
  ) public returns (VoxelEntity memory, VoxelEntity memory) {
    MoveWorldEventData memory moveWorldEventData = MoveWorldEventData({ agentEntity: agentEntity });
    (VoxelEntity memory oldEntity, VoxelEntity memory newEntity) = move(
      voxelTypeId,
      newCoord,
      abi.encode(MoveEventData({ oldCoord: oldCoord, worldData: abi.encode(moveWorldEventData) }))
    );
    console.log("post move");
    console.logBytes32(agentEntity.entityId);
    console.logInt(oldCoord.x);
    console.logInt(oldCoord.y);
    console.logInt(oldCoord.z);
    console.logBytes32(oldEntity.entityId);
    console.logInt(newCoord.x);
    console.logInt(newCoord.y);
    console.logInt(newCoord.z);
    console.logBytes32(newEntity.entityId);

    // Transfer ownership of the oldEntity to the newEntity
    if (
      hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(oldEntity.scale, oldEntity.entityId)) &&
      !isEntityEqual(oldEntity, newEntity)
    ) {
      console.log("ownership transfer");
      console.logAddress(OwnedBy.get(oldEntity.scale, oldEntity.entityId));
      OwnedBy.set(newEntity.scale, newEntity.entityId, OwnedBy.get(oldEntity.scale, oldEntity.entityId));
      OwnedBy.deleteRecord(oldEntity.scale, oldEntity.entityId);
    }

    return (oldEntity, newEntity);
  }

  function preRunCA(
    address caAddress,
    bytes32 voxelTypeId,
    VoxelCoord memory newCoord,
    VoxelEntity memory eventVoxelEntity,
    bytes memory eventData
  ) internal override returns (VoxelEntity memory) {
    eventVoxelEntity = super.preRunCA(caAddress, voxelTypeId, newCoord, eventVoxelEntity, eventData);
    MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
    VoxelCoord memory oldCoord = moveEventData.oldCoord;
    uint32 scale = eventVoxelEntity.scale;
    VoxelEntity memory oldEntity = VoxelEntity({ scale: scale, entityId: getEntityAtCoord(scale, oldCoord) });

    MoveWorldEventData memory moveWorldEventData = abi.decode(moveEventData.worldData, (MoveWorldEventData));
    console.log("calling sim on move");
    VoxelEntity memory postMoveNewEntity = onMove(
      SIMULATOR_ADDRESS,
      moveWorldEventData.agentEntity,
      oldEntity,
      oldCoord,
      eventVoxelEntity,
      newCoord
    );
    return postMoveNewEntity;
  }
}
