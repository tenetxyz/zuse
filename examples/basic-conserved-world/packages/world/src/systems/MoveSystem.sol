// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { MoveEvent } from "@tenet-base-world/src/prototypes/MoveEvent.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { abs, absInt32 } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { MoveEventData } from "@tenet-base-world/src/Types.sol";
import { OwnedBy, OwnedByTableId, BodyPhysics, BodyPhysicsData, BodyPhysicsTableId, WorldConfig, VoxelTypeProperties } from "@tenet-world/src/codegen/Tables.sol";
import { MoveWorldEventData } from "@tenet-world/src/Types.sol";

contract MoveSystem is MoveEvent {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
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

    address caAddress = WorldConfig.get(voxelTypeId);
    IWorld(_world()).updateVelocity(caAddress, oldCoord, newCoord, oldEntity, newEntity);

    // Transfer ownership of the oldEntity to the newEntity
    if (hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(oldEntity.scale, oldEntity.entityId))) {
      OwnedBy.set(newEntity.scale, newEntity.entityId, OwnedBy.get(oldEntity.scale, oldEntity.entityId));
      OwnedBy.deleteRecord(oldEntity.scale, oldEntity.entityId);
    }

    return (oldEntity, newEntity);
  }
}
