// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Health, HealthTableId, Stamina, StaminaTableId, Object, ObjectTableId, Action, ActionData, ActionTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ObjectType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { uint256ToInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { console } from "forge-std/console.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";

contract CallerEventSystem is System {
  function onBuild(VoxelEntity memory entity, VoxelCoord memory coord, uint256 entityMass) public {
    address callerAddress = _msgSender();
    bool entityExists = hasKey(MassTableId, Mass.encodeKeyTuple(callerAddress, entity.scale, entity.entityId));
    require(entityMass > 0, "Mass must be greater than zero to build");
    if (entityExists) {
      uint256 currentMass = Mass.get(callerAddress, entity.scale, entity.entityId);
      require(currentMass == 0, "Mass must be zero to build");
    } else {
      uint256 terrainMass = getTerrainMass(callerAddress, entity.scale, coord);
      require(terrainMass == 0 || terrainMass == entityMass, "Invalid terrain mass");

      // Set initial values
      Mass.set(callerAddress, entity.scale, entity.entityId, 0); // Set to zero to prevent double build
      Energy.set(callerAddress, entity.scale, entity.entityId, getTerrainEnergy(callerAddress, entity.scale, coord));
      Velocity.set(
        callerAddress,
        entity.scale,
        entity.entityId,
        block.number,
        abi.encode(getTerrainVelocity(callerAddress, entity.scale, coord))
      );
    }

    int256 massDelta = uint256ToInt256(entityMass);
    IWorld(_world()).updateMass(entity, coord, massDelta, entity, coord, massDelta);
  }

  function onMine(VoxelEntity memory entity, VoxelCoord memory coord) public {
    address callerAddress = _msgSender();
    bool entityExists = hasKey(MassTableId, Mass.encodeKeyTuple(callerAddress, entity.scale, entity.entityId));
    int256 massDelta;
    if (entityExists) {
      require(isZeroCoord(getVelocity(callerAddress, entity)), "Cannot mine an entity with velocity");
      uint256 currentMass = Mass.get(callerAddress, entity.scale, entity.entityId);
      if (currentMass == 0) {
        return;
      }
      massDelta = -1 * uint256ToInt256(currentMass);
    } else {
      VoxelCoord memory terrainVelocity = getTerrainVelocity(callerAddress, entity.scale, coord);
      uint256 terrainMass = getTerrainMass(callerAddress, entity.scale, coord);
      require(isZeroCoord(terrainVelocity), "Cannot mine terrain with velocity");
      // Set initial values
      Mass.set(callerAddress, entity.scale, entity.entityId, terrainMass);
      Energy.set(callerAddress, entity.scale, entity.entityId, getTerrainEnergy(callerAddress, entity.scale, coord));
      Velocity.set(callerAddress, entity.scale, entity.entityId, block.number, abi.encode(terrainVelocity));

      if (terrainMass == 0) {
        return;
      }
      massDelta = -1 * uint256ToInt256(terrainMass);
    }

    IWorld(_world()).updateMass(entity, coord, massDelta, entity, coord, massDelta);
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
    if (hasKey(HealthTableId, Health.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
      uint256 health = Health.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Health.set(callerAddress, newEntity.scale, newEntity.entityId, health);
      Health.set(callerAddress, oldEntity.scale, oldEntity.entityId, 0);
    }

    if (hasKey(ObjectTableId, Object.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
      ObjectType objectType = Object.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Object.set(callerAddress, newEntity.scale, newEntity.entityId, objectType);
      Object.set(callerAddress, oldEntity.scale, oldEntity.entityId, ObjectType.None);
    }

    if (hasKey(ActionTableId, Action.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
      ActionData memory actionData = Action.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Action.set(callerAddress, newEntity.scale, newEntity.entityId, actionData);
      ActionData memory emptyActionData;
      Action.set(callerAddress, oldEntity.scale, oldEntity.entityId, emptyActionData);
    }
  }

  function onActivate(VoxelEntity memory entity, VoxelCoord memory coord) public {}
}
