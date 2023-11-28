// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, EventType } from "@tenet-utils/src/Types.sol";
import { WorldMoveEventSystem as WorldMoveEventProtoSystem } from "@tenet-base-simulator/src/systems/WorldMoveEventSystem.sol";
import { getEntityIdFromObjectEntityId } from "@tenet-base-world/src/Utils.sol";

contract WorldMoveEventSystem is WorldMoveEventProtoSystem {
  function preMoveEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord
  ) public override {}

  function onMoveEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bytes32 objectEntityId
  ) public override returns (bytes32) {
    address world = _msgSender();
    return getEntityIdFromObjectEntityId(IStore(world), objectEntityId);
  }

  // function velocityChange(
  //   VoxelEntity memory actingEntity,
  //   VoxelCoord memory oldCoord,
  //   VoxelCoord memory newCoord,
  //   VoxelEntity memory oldEntity,
  //   VoxelEntity memory newEntity
  // ) public returns (VoxelEntity memory) {
  //   // TODO: make this only callable by the simulator
  //   address callerAddress = super.getCallerAddress();
  //   require(
  //     hasKey(MassTableId, Mass.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId)),
  //     "Old entity does not exist"
  //   );
  //   EntityData memory oldEntityData;
  //   oldEntityData.mass = Mass.get(callerAddress, oldEntity.scale, oldEntity.entityId);
  //   (VoxelCoord memory newVelocity, uint256 resourceRequired) = calculateNewVelocity(
  //     callerAddress,
  //     oldCoord,
  //     newCoord,
  //     oldEntity,
  //     oldEntityData.mass
  //   );
  //   MovementResource resourceToConsume = hasKey(
  //     StaminaTableId,
  //     Stamina.encodeKeyTuple(callerAddress, actingEntity.scale, actingEntity.entityId)
  //   )
  //     ? MovementResource.Stamina
  //     : MovementResource.Temperature;
  //   oldEntityData.resource = resourceToConsume == MovementResource.Stamina
  //     ? Stamina.get(callerAddress, actingEntity.scale, actingEntity.entityId)
  //     : Temperature.get(callerAddress, actingEntity.scale, actingEntity.entityId);
  //   require(resourceRequired <= oldEntityData.resource, "Not enough resources to move.");

  //   if (hasKey(MassTableId, Mass.encodeKeyTuple(callerAddress, newEntity.scale, newEntity.entityId))) {
  //     require(
  //       Mass.get(callerAddress, newEntity.scale, newEntity.entityId) == 0,
  //       "Cannot move on top of an entity with mass"
  //     );
  //   } else {
  //     initTerrainEntity(callerAddress, oldEntity.scale, newCoord, newEntity);
  //   }
  //   oldEntityData.energy = Energy.get(callerAddress, oldEntity.scale, oldEntity.entityId);
  //   uint256 resourceInOldEntity = resourceToConsume == MovementResource.Stamina
  //     ? Stamina.get(callerAddress, oldEntity.scale, oldEntity.entityId)
  //     : Temperature.get(callerAddress, oldEntity.scale, oldEntity.entityId);

  //   // Reset the old entity's mass, energy and velocity
  //   Mass.set(callerAddress, oldEntity.scale, oldEntity.entityId, 0);
  //   Energy.set(callerAddress, oldEntity.scale, oldEntity.entityId, 0);
  //   Velocity.set(
  //     callerAddress,
  //     oldEntity.scale,
  //     oldEntity.entityId,
  //     block.number,
  //     abi.encode(VoxelCoord({ x: 0, y: 0, z: 0 }))
  //   );
  //   if (hasKey(StaminaTableId, Stamina.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
  //     Stamina.set(callerAddress, oldEntity.scale, oldEntity.entityId, 0);
  //   }

  //   fluxEnergyForMove(callerAddress, newEntity, resourceRequired);

  //   // Update the new entity's energy and velocity
  //   Mass.set(callerAddress, newEntity.scale, newEntity.entityId, oldEntityData.mass);
  //   Energy.set(callerAddress, newEntity.scale, newEntity.entityId, oldEntityData.energy);
  //   Velocity.set(callerAddress, newEntity.scale, newEntity.entityId, block.number, abi.encode(newVelocity));
  //   // VoxelEntity memory newActingEntity = actingEntity;
  //   if (isEntityEqual(oldEntity, actingEntity)) {
  //     // newActingEntity = newEntity; // moving yourself, so update the acting entity
  //     if (resourceToConsume == MovementResource.Stamina) {
  //       Stamina.set(callerAddress, newEntity.scale, newEntity.entityId, oldEntityData.resource - resourceRequired);
  //     } else {
  //       Temperature.set(callerAddress, newEntity.scale, newEntity.entityId, oldEntityData.resource - resourceRequired);
  //     }
  //   } else {
  //     if (hasKey(StaminaTableId, Stamina.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
  //       Stamina.set(callerAddress, newEntity.scale, newEntity.entityId, resourceInOldEntity);
  //     }
  //     // if (hasKey(TemperatureTableId, Temperature.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
  //     //   Temperature.set(callerAddress, newEntity.scale, newEntity.entityId, resourceInOldEntity);
  //     // }
  //     if (resourceToConsume == MovementResource.Stamina) {
  //       Stamina.set(
  //         callerAddress,
  //         actingEntity.scale,
  //         actingEntity.entityId,
  //         oldEntityData.resource - resourceRequired
  //       );
  //     } else {
  //       Temperature.set(
  //         callerAddress,
  //         actingEntity.scale,
  //         actingEntity.entityId,
  //         oldEntityData.resource - resourceRequired
  //       );
  //     }
  //   }

  //   return callOnCollision(callerAddress, actingEntity, oldEntity, newEntity);
  // }

  function postMoveEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bytes32 objectEntityId
  ) public override {}
}
