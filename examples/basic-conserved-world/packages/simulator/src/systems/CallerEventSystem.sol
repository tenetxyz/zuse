// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Health, Stamina, Object, Action, ActionData, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ObjectType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { console } from "forge-std/console.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";

contract CallerEventSystem is System {
  function onBuild(VoxelEntity memory entity, VoxelCoord memory coord, uint256 entityMass) public {
    address callerAddress = _msgSender();
    uint256 currentMass = Mass.get(callerAddress, entity.scale, entity.entityId);
    if (currentMass != entityMass) {
      IWorld(_world()).setMass(entity, coord, currentMass, entity, coord, entityMass);
    }
  }

  function onMine(VoxelEntity memory entity, VoxelCoord memory coord) public {
    address callerAddress = _msgSender();
    uint256 currentMass = Mass.get(callerAddress, entity.scale, entity.entityId);
    if (currentMass > 0) {
      IWorld(_world()).setMass(entity, coord, currentMass, entity, coord, 0);
    }
  }

  function onMove(
    VoxelEntity memory oldEntity,
    VoxelCoord memory oldCoord,
    VoxelEntity memory newEntity,
    VoxelCoord memory newCoord
  ) public {
    address callerAddress = _msgSender();
    IWorld(_world()).velocityChange(oldCoord, newCoord, oldEntity, newEntity);

    // Transfer ownership of other tables
    uint256 health = Health.get(callerAddress, oldEntity.scale, oldEntity.entityId);
    uint256 stamina = Stamina.get(callerAddress, oldEntity.scale, oldEntity.entityId);
    ObjectType objectType = Object.get(callerAddress, oldEntity.scale, oldEntity.entityId);
    ActionData memory actionData = Action.get(callerAddress, oldEntity.scale, oldEntity.entityId);

    // Set new
    Health.set(callerAddress, newEntity.scale, newEntity.entityId, health);
    Stamina.set(callerAddress, newEntity.scale, newEntity.entityId, stamina);
    Object.set(callerAddress, newEntity.scale, newEntity.entityId, objectType);
    Action.set(callerAddress, newEntity.scale, newEntity.entityId, actionData);

    // Reset old
    Health.set(callerAddress, oldEntity.scale, oldEntity.entityId, 0);
    Stamina.set(callerAddress, oldEntity.scale, oldEntity.entityId, 0);
    Object.set(callerAddress, oldEntity.scale, oldEntity.entityId, ObjectType.None);
    ActionData memory emptyActionData;
    Action.set(callerAddress, oldEntity.scale, oldEntity.entityId, emptyActionData);
  }

  function onActivate(VoxelEntity memory entity, VoxelCoord memory coord) public {}
}
