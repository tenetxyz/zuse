// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Metadata, MetadataTableId, Nitrogen, NitrogenTableId, Phosphorous, PhosphorousTableId, Potassium, PotassiumTableId, Nutrients, NutrientsTableId, Elixir, ElixirTableId, Protein, ProteinTableId, Health, HealthTableId, Stamina, StaminaTableId, Object, ObjectTableId, Action, ActionData, ActionTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ObjectType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { uint256ToInt256, uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { console } from "forge-std/console.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";

uint256 constant TX_SPEED_RATIO = 90;
uint256 constant MAX_BLOCKS_TO_WAIT = 60 * 5; // 5 minutes if 1 block = 1 second

contract CallerEventSystem is System {
  function preEvent(address callerAddress, VoxelEntity memory actingEntity) internal {
    // Check if entity has health
    if (hasKey(HealthTableId, Health.encodeKeyTuple(callerAddress, actingEntity.scale, actingEntity.entityId))) {
      uint256 health = Health.get(callerAddress, actingEntity.scale, actingEntity.entityId);
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
    uint256 currentHealth = Health.get(callerAddress, entity.scale, entity.entityId);
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

  function onMove(
    VoxelEntity memory actingEntity,
    VoxelEntity memory oldEntity,
    VoxelCoord memory oldCoord,
    VoxelEntity memory newEntity,
    VoxelCoord memory newCoord
  ) public {
    address callerAddress = _msgSender();
    preEvent(callerAddress, actingEntity);
    IWorld(_world()).velocityChange(actingEntity, oldCoord, newCoord, oldEntity, newEntity);

    if (hasKey(MetadataTableId, Metadata.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
      uint256 lastInteractionBlock = Metadata.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Metadata.set(callerAddress, newEntity.scale, newEntity.entityId, lastInteractionBlock);
      Metadata.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    // Transfer ownership of other tables
    if (hasKey(HealthTableId, Health.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
      uint256 health = Health.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Health.set(callerAddress, newEntity.scale, newEntity.entityId, health);
      Health.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (hasKey(ObjectTableId, Object.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
      ObjectType objectType = Object.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Object.set(callerAddress, newEntity.scale, newEntity.entityId, objectType);
      Object.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (hasKey(ActionTableId, Action.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
      ActionData memory actionData = Action.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Action.set(callerAddress, newEntity.scale, newEntity.entityId, actionData);
      Action.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (hasKey(NutrientsTableId, Nutrients.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
      uint256 nutrients = Nutrients.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Nutrients.set(callerAddress, newEntity.scale, newEntity.entityId, nutrients);
      Nutrients.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (hasKey(ElixirTableId, Elixir.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
      uint256 elixir = Elixir.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Elixir.set(callerAddress, newEntity.scale, newEntity.entityId, elixir);
      Elixir.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (hasKey(ProteinTableId, Protein.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
      uint256 protein = Protein.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Protein.set(callerAddress, newEntity.scale, newEntity.entityId, protein);
      Protein.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (hasKey(NitrogenTableId, Nitrogen.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
      uint256 nitrogen = Nitrogen.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Nitrogen.set(callerAddress, newEntity.scale, newEntity.entityId, nitrogen);
      Nitrogen.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (hasKey(PhosphorousTableId, Phosphorous.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
      uint256 phosphorous = Phosphorous.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Phosphorous.set(callerAddress, newEntity.scale, newEntity.entityId, phosphorous);
      Phosphorous.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (hasKey(PotassiumTableId, Potassium.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId))) {
      uint256 potassium = Potassium.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Potassium.set(callerAddress, newEntity.scale, newEntity.entityId, potassium);
      Potassium.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }
  }

  function onActivate(VoxelEntity memory actingEntity, VoxelEntity memory entity, VoxelCoord memory coord) public {
    address callerAddress = _msgSender();
    preEvent(callerAddress, actingEntity);
  }
}
