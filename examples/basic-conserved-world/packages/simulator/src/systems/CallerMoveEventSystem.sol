// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Temperature, TemperatureTableId, Metadata, MetadataTableId, Nitrogen, NitrogenTableId, Phosphorous, PhosphorousTableId, Potassium, PotassiumTableId, Nutrients, NutrientsTableId, Elixir, ElixirTableId, Protein, ProteinTableId, Health, HealthTableId, Stamina, StaminaTableId, Object, ObjectTableId, Action, ActionData, ActionTableId, Mass, MassTableId, Energy, EnergyTableId, Velocity, VelocityTableId } from "@tenet-simulator/src/codegen/Tables.sol";
import { VoxelCoord, VoxelTypeData, VoxelEntity, ObjectType } from "@tenet-utils/src/Types.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData } from "@tenet-registry/src/codegen/tables/VoxelTypeRegistry.sol";
import { distanceBetween, voxelCoordsAreEqual, isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { uint256ToInt256, uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { isEntityEqual } from "@tenet-utils/src/Utils.sol";
import { console } from "forge-std/console.sol";
import { getVelocity, getTerrainMass, getTerrainEnergy, getTerrainVelocity } from "@tenet-simulator/src/Utils.sol";
import { TX_SPEED_RATIO, MAX_BLOCKS_TO_WAIT } from "@tenet-simulator/src/Constants.sol";

contract CallerMoveEventSystem is System {
  // TODO: merge with the one in CallerEventSystem
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

  function onMove(
    VoxelEntity memory actingEntity,
    VoxelEntity memory oldEntity,
    VoxelCoord memory oldCoord,
    VoxelEntity memory newEntity,
    VoxelCoord memory newCoord
  ) public returns (VoxelEntity memory) {
    address callerAddress = _msgSender();
    preEvent(callerAddress, actingEntity);
    VoxelEntity memory postNewEntity = IWorld(_world()).velocityChange(
      actingEntity,
      oldCoord,
      newCoord,
      oldEntity,
      newEntity
    );

    if (
      hasKey(MetadataTableId, Metadata.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId)) &&
      !isEntityEqual(oldEntity, postNewEntity)
    ) {
      uint256 lastInteractionBlock = Metadata.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Metadata.set(callerAddress, postNewEntity.scale, postNewEntity.entityId, lastInteractionBlock);
      Metadata.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    // Transfer ownership of other tables
    if (
      hasKey(HealthTableId, Health.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId)) &&
      !isEntityEqual(oldEntity, postNewEntity)
    ) {
      uint256 health = Health.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Health.set(callerAddress, postNewEntity.scale, postNewEntity.entityId, health);
      Health.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (
      hasKey(ObjectTableId, Object.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId)) &&
      !isEntityEqual(oldEntity, postNewEntity)
    ) {
      ObjectType objectType = Object.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Object.set(callerAddress, postNewEntity.scale, postNewEntity.entityId, objectType);
      Object.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (
      hasKey(ActionTableId, Action.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId)) &&
      !isEntityEqual(oldEntity, postNewEntity)
    ) {
      ActionData memory actionData = Action.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Action.set(callerAddress, postNewEntity.scale, postNewEntity.entityId, actionData);
      Action.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (
      hasKey(NutrientsTableId, Nutrients.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId)) &&
      !isEntityEqual(oldEntity, postNewEntity)
    ) {
      uint256 nutrients = Nutrients.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Nutrients.set(callerAddress, postNewEntity.scale, postNewEntity.entityId, nutrients);
      Nutrients.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (
      hasKey(ElixirTableId, Elixir.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId)) &&
      !isEntityEqual(oldEntity, postNewEntity)
    ) {
      uint256 elixir = Elixir.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Elixir.set(callerAddress, postNewEntity.scale, postNewEntity.entityId, elixir);
      Elixir.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (
      hasKey(ProteinTableId, Protein.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId)) &&
      !isEntityEqual(oldEntity, postNewEntity)
    ) {
      uint256 protein = Protein.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Protein.set(callerAddress, postNewEntity.scale, postNewEntity.entityId, protein);
      Protein.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (
      hasKey(NitrogenTableId, Nitrogen.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId)) &&
      !isEntityEqual(oldEntity, postNewEntity)
    ) {
      uint256 nitrogen = Nitrogen.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Nitrogen.set(callerAddress, postNewEntity.scale, postNewEntity.entityId, nitrogen);
      Nitrogen.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (
      hasKey(PhosphorousTableId, Phosphorous.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId)) &&
      !isEntityEqual(oldEntity, postNewEntity)
    ) {
      uint256 phosphorous = Phosphorous.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Phosphorous.set(callerAddress, postNewEntity.scale, postNewEntity.entityId, phosphorous);
      Phosphorous.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (
      hasKey(PotassiumTableId, Potassium.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId)) &&
      !isEntityEqual(oldEntity, postNewEntity)
    ) {
      uint256 potassium = Potassium.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Potassium.set(callerAddress, postNewEntity.scale, postNewEntity.entityId, potassium);
      Potassium.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    if (
      hasKey(TemperatureTableId, Temperature.encodeKeyTuple(callerAddress, oldEntity.scale, oldEntity.entityId)) &&
      !isEntityEqual(oldEntity, postNewEntity)
    ) {
      uint256 temperature = Temperature.get(callerAddress, oldEntity.scale, oldEntity.entityId);
      Temperature.set(callerAddress, postNewEntity.scale, postNewEntity.entityId, temperature);
      Temperature.deleteRecord(callerAddress, oldEntity.scale, oldEntity.entityId);
    }

    return postNewEntity;
  }
}
