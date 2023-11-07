// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Temperature, Metadata, MetadataTableId, Nitrogen, NitrogenTableId, Phosphorous, PhosphorousTableId, Potassium, PotassiumTableId, Nutrients, NutrientsTableId, Elixir, ElixirTableId, Protein, ProteinTableId, Health, HealthTableId, Stamina, StaminaTableId, Object, ObjectTableId, Action, ActionData, ActionTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ObjectType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { uint256ToInt256, uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";
import { TX_SPEED_RATIO, MAX_BLOCKS_TO_WAIT } from "@tenet-simulator/src/Constants.sol";

contract CallerEventSystem is System {
  function preEvent(address callerAddress, VoxelEntity memory actingEntity) internal {
    // Check if entity has health
    if (hasKey(HealthTableId, Health.encodeKeyTuple(callerAddress, actingEntity.scale, actingEntity.entityId))) {
      uint256 health = Health.getHealth(callerAddress, actingEntity.scale, actingEntity.entityId);
      // blocks to wait = K / health
      uint256 blocksToWait;
      if (health == 0) {
        blocksToWait = MAX_BLOCKS_TO_WAIT;
      } else {
        blocksToWait = TX_SPEED_RATIO / health;
      }
      // Check if enough time has passed
      uint256 lastBlock = Metadata.get(callerAddress, actingEntity.scale, actingEntity.entityId);
      if (lastBlock == 0 || block.number - lastBlock >= blocksToWait) {
        Metadata.set(callerAddress, actingEntity.scale, actingEntity.entityId, block.number);
      } else {
        revert("Not enough time has passed since last event based on current health");
      }
    }
  }

  function onBuild(
    VoxelEntity memory actingEntity,
    VoxelEntity memory entity,
    VoxelCoord memory coord,
    uint256 entityMass
  ) public {
    address callerAddress = _msgSender();
    preEvent(callerAddress, actingEntity);
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

    IWorld(_world()).temperatureBehaviour(callerAddress, entity);
  }

  function onMine(VoxelEntity memory actingEntity, VoxelEntity memory entity, VoxelCoord memory coord) public {
    address callerAddress = _msgSender();
    preEvent(callerAddress, actingEntity);
    bool entityExists = hasKey(MassTableId, Mass.encodeKeyTuple(callerAddress, entity.scale, entity.entityId));
    int256 massDelta;
    if (entityExists) {
      require(isZeroCoord(getVelocity(callerAddress, entity)), "Cannot mine an entity with velocity");
      uint256 currentMass = Mass.get(callerAddress, entity.scale, entity.entityId);
      if (currentMass > 0) {
        massDelta = -1 * uint256ToInt256(currentMass);
      }
    } else {
      VoxelCoord memory terrainVelocity = getTerrainVelocity(callerAddress, entity.scale, coord);
      uint256 terrainMass = getTerrainMass(callerAddress, entity.scale, coord);
      require(isZeroCoord(terrainVelocity), "Cannot mine terrain with velocity");
      // Set initial values
      Mass.set(callerAddress, entity.scale, entity.entityId, terrainMass);
      Energy.set(callerAddress, entity.scale, entity.entityId, getTerrainEnergy(callerAddress, entity.scale, coord));
      Velocity.set(callerAddress, entity.scale, entity.entityId, block.number, abi.encode(terrainVelocity));

      if (terrainMass > 0) {
        massDelta = -1 * uint256ToInt256(terrainMass);
      }
    }

    if (massDelta != 0) {
      IWorld(_world()).updateMass(entity, coord, massDelta, entity, coord, massDelta);
    }

    // Update forms of energy to general energy
    uint256 currentHealth = Health.getHealth(callerAddress, entity.scale, entity.entityId);
    if (currentHealth > 0) {
      IWorld(_world()).updateHealthFromEnergy(
        entity,
        coord,
        uint256ToInt256(currentHealth),
        entity,
        coord,
        uint256ToNegativeInt256(currentHealth)
      );
    }
    uint256 currentStamina = Stamina.get(callerAddress, entity.scale, entity.entityId);
    if (currentStamina > 0) {
      IWorld(_world()).updateStaminaFromEnergy(
        entity,
        coord,
        uint256ToInt256(currentStamina),
        entity,
        coord,
        uint256ToNegativeInt256(currentStamina)
      );
    }
    uint256 currentNutrients = Nutrients.get(callerAddress, entity.scale, entity.entityId);
    if (currentNutrients > 0) {
      IWorld(_world()).updateNutrientsFromEnergy(
        entity,
        coord,
        uint256ToInt256(currentNutrients),
        entity,
        coord,
        uint256ToNegativeInt256(currentNutrients)
      );
    }
    uint256 currentTemperature = Temperature.get(callerAddress, entity.scale, entity.entityId);
    if (currentTemperature > 0) {
      IWorld(_world()).updateTemperatureFromEnergy(
        entity,
        coord,
        uint256ToInt256(currentTemperature),
        entity,
        coord,
        uint256ToNegativeInt256(currentTemperature)
      );
    }
    uint256 currentElixir = Elixir.get(callerAddress, entity.scale, entity.entityId);
    if (currentElixir > 0) {
      IWorld(_world()).updateElixirFromEnergy(
        entity,
        coord,
        uint256ToInt256(currentElixir),
        entity,
        coord,
        uint256ToNegativeInt256(currentElixir)
      );
    }
    uint256 currentProtein = Protein.get(callerAddress, entity.scale, entity.entityId);
    if (currentProtein > 0) {
      IWorld(_world()).updateProteinFromEnergy(
        entity,
        coord,
        uint256ToInt256(currentProtein),
        entity,
        coord,
        uint256ToNegativeInt256(currentProtein)
      );
    }

    // Delete properties
    if (hasKey(MetadataTableId, Metadata.encodeKeyTuple(callerAddress, entity.scale, entity.entityId))) {
      Metadata.deleteRecord(callerAddress, entity.scale, entity.entityId);
    }

    if (hasKey(ObjectTableId, Object.encodeKeyTuple(callerAddress, entity.scale, entity.entityId))) {
      Object.deleteRecord(callerAddress, entity.scale, entity.entityId);
    }

    if (hasKey(ActionTableId, Action.encodeKeyTuple(callerAddress, entity.scale, entity.entityId))) {
      Action.deleteRecord(callerAddress, entity.scale, entity.entityId);
    }

    if (hasKey(NitrogenTableId, Nitrogen.encodeKeyTuple(callerAddress, entity.scale, entity.entityId))) {
      Nitrogen.deleteRecord(callerAddress, entity.scale, entity.entityId);
    }

    if (hasKey(PhosphorousTableId, Phosphorous.encodeKeyTuple(callerAddress, entity.scale, entity.entityId))) {
      Phosphorous.deleteRecord(callerAddress, entity.scale, entity.entityId);
    }

    if (hasKey(PotassiumTableId, Potassium.encodeKeyTuple(callerAddress, entity.scale, entity.entityId))) {
      Potassium.deleteRecord(callerAddress, entity.scale, entity.entityId);
    }
  }

  function onActivate(VoxelEntity memory actingEntity, VoxelEntity memory entity, VoxelCoord memory coord) public {
    address callerAddress = _msgSender();
    preEvent(callerAddress, actingEntity);
    IWorld(_world()).temperatureBehaviour(callerAddress, entity);
  }

  function postTx(VoxelEntity memory actingEntity, VoxelEntity memory entity, VoxelCoord memory coord) public {
    IWorld(_world()).postTxActionBehaviour();
  }
}
