// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { MoveEvent } from "@tenet-base-world/src/prototypes/MoveEvent.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { IWorld } from "@tenet-world/src/codegen/world/IWorld.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { MoveEventData } from "@tenet-base-world/src/Types.sol";
import { OwnedBy, OwnedByTableId, BodyPhysics, BodyPhysicsData, BodyPhysicsTableId, WorldConfig, VoxelTypeProperties } from "@tenet-world/src/codegen/Tables.sol";
import { MoveWorldEventData } from "@tenet-world/src/Types.sol";
import { getVelocity } from "@tenet-world/src/Utils.sol";

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

    // Read current velocity
    VoxelCoord memory currentVelocity = getVelocity(oldEntity);
    VoxelCoord memory newVelocity = VoxelCoord({
      x: currentVelocity.x + (newCoord.x - oldCoord.x),
      y: currentVelocity.y + (newCoord.y - oldCoord.y),
      z: currentVelocity.z + (newCoord.z - oldCoord.z)
    });
    VoxelCoord memory velocityDelta = VoxelCoord({
      x: newVelocity.x - currentVelocity.x,
      y: newVelocity.y - currentVelocity.y,
      z: newVelocity.z - currentVelocity.z
    });

    BodyPhysicsData memory bodyPhysicsData = BodyPhysics.get(oldEntity.scale, oldEntity.entityId);
    uint256 bodyMass = bodyPhysicsData.mass;

    uint256 energyRequiredX = velocityDelta.x > 0
      ? bodyMass / uint(int(velocityDelta.x)) // if we're going in the same direction, then it costs less
      : bodyMass * uint(int(velocityDelta.x)); // if we're going in the opposite direction, then it costs more
    uint256 energyRequiredY = velocityDelta.y > 0
      ? bodyMass / uint(int(velocityDelta.y))
      : bodyMass * uint(int(velocityDelta.y));
    uint256 energyRequiredZ = velocityDelta.z > 0
      ? bodyMass / uint(int(velocityDelta.z))
      : bodyMass * uint(int(velocityDelta.z));
    uint256 energyRequired = energyRequiredX + energyRequiredY + energyRequiredZ;
    require(energyRequired <= bodyPhysicsData.energy, "Not enough energy to move.");

    address caAddress = WorldConfig.get(voxelTypeId);
    if (!hasKey(BodyPhysicsTableId, BodyPhysics.encodeKeyTuple(newEntity.scale, newEntity.entityId))) {
      (, BodyPhysicsData memory terrainPhysicsData) = IWorld(_world()).getTerrainBodyPhysicsData(caAddress, newCoord);
      BodyPhysics.set(newEntity.scale, newEntity.entityId, terrainPhysicsData);
    }
    uint256 energyInNewBlock = BodyPhysics.getEnergy(newEntity.scale, newEntity.entityId);

    BodyPhysics.setMass(oldEntity.scale, oldEntity.entityId, 0);
    BodyPhysics.setEnergy(oldEntity.scale, oldEntity.entityId, 0);
    BodyPhysics.setVelocity(oldEntity.scale, oldEntity.entityId, abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 })));
    IWorld(_world()).fluxEnergy(false, caAddress, newEntity, energyRequired + energyInNewBlock);
    BodyPhysics.setEnergy(newEntity.scale, newEntity.entityId, bodyPhysicsData.energy - energyRequired);

    // Transfer ownership of the oldEntity to the newEntity
    if (hasKey(OwnedByTableId, OwnedBy.encodeKeyTuple(oldEntity.scale, oldEntity.entityId))) {
      OwnedBy.set(newEntity.scale, newEntity.entityId, OwnedBy.get(oldEntity.scale, oldEntity.entityId));
      OwnedBy.deleteRecord(oldEntity.scale, oldEntity.entityId);
    }

    return (oldEntity, newEntity);
  }
}
