// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { WorldMineEventSystem as WorldMineEventProtoSystem } from "@tenet-base-simulator/src/systems/WorldMineEventSystem.sol";

import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Health, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Energy, EnergyTableId } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Nitrogen, NitrogenTableId } from "@tenet-simulator/src/codegen/tables/Nitrogen.sol";
import { Phosphorus, PhosphorusTableId } from "@tenet-simulator/src/codegen/tables/Phosphorus.sol";
import { Potassium, PotassiumTableId } from "@tenet-simulator/src/codegen/tables/Potassium.sol";
import { Nutrients, NutrientsTableId } from "@tenet-simulator/src/codegen/tables/Nutrients.sol";
import { Protein, ProteinTableId } from "@tenet-simulator/src/codegen/tables/Protein.sol";
import { Elixir, ElixirTableId } from "@tenet-simulator/src/codegen/tables/Elixir.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Metadata, MetadataTableId } from "@tenet-simulator/src/codegen/tables/Metadata.sol";
import { Element, ElementTableId } from "@tenet-simulator/src/codegen/tables/Element.sol";
import { CombatMove, CombatMoveTableId } from "@tenet-simulator/src/codegen/tables/CombatMove.sol";
import { Temperature, TemperatureTableId } from "@tenet-simulator/src/codegen/tables/Temperature.sol";

import { VoxelCoord, EventType, ActionType, SimTable } from "@tenet-utils/src/Types.sol";
import { getVelocity } from "@tenet-simulator/src/Utils.sol";
import { isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { uint256ToInt256, uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { runSimAction } from "@tenet-base-simulator/src/CallUtils.sol";

contract WorldMineEventSystem is WorldMineEventProtoSystem {
  function preMineEvent(bytes32 actingObjectEntityId, bytes32 objectTypeId, VoxelCoord memory coord) public override {
    // address worldAddress = _msgSender();
    // IWorld(_world()).checkActingObjectHealth(worldAddress, actingObjectEntityId);
    // IWorld(_world()).updateVelocityCache(worldAddress, actingObjectEntityId);
  }

  function onMineEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public override {
    address worldAddress = _msgSender();
    // if (objectEntityId != actingObjectEntityId) {
    //   IWorld(_world()).updateVelocityCache(worldAddress, objectEntityId);
    // }

    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, objectEntityId)),
      "WorldMineEventSystem: Entity is not initialized"
    );
    require(
      isZeroCoord(getVelocity(worldAddress, objectEntityId)),
      "WorldMineEventSystem: Cannot mine an entity with velocity"
    );
    uint256 currentMass = Mass.get(worldAddress, objectEntityId);
    require(currentMass > 0, "WorldMineEventSystem: Mass must be greater than zero to mine");

    IWorld(_world()).massTransformation(
      objectEntityId,
      coord,
      abi.encode(currentMass),
      abi.encode(-1 * uint256ToInt256(currentMass))
    );

    transformEnergyFormsToGeneralEnergy(worldAddress, objectEntityId, coord);
    deleteProperties(worldAddress, objectEntityId);
  }

  function transformEnergyFormsToGeneralEnergy(
    address worldAddress,
    bytes32 objectEntityId,
    VoxelCoord memory coord
  ) internal {
    uint256 currentNutrients = Nutrients.get(worldAddress, objectEntityId);
    if (currentNutrients > 0) {
      (bool transformSuccess, ) = runSimAction(
        _world(),
        ActionType.Transformation,
        objectEntityId,
        coord,
        SimTable.Energy,
        abi.encode(uint256ToInt256(currentNutrients)),
        objectEntityId,
        coord,
        SimTable.Nutrients,
        abi.encode(uint256ToNegativeInt256(currentNutrients))
      );
      require(transformSuccess, "WorldMineEventSystem: Failed to transform nutrients to energy");
    }
    uint256 currentElixir = Elixir.get(worldAddress, objectEntityId);
    if (currentElixir > 0) {
      (bool transformSuccess, ) = runSimAction(
        _world(),
        ActionType.Transformation,
        objectEntityId,
        coord,
        SimTable.Energy,
        abi.encode(uint256ToInt256(currentElixir)),
        objectEntityId,
        coord,
        SimTable.Elixir,
        abi.encode(uint256ToNegativeInt256(currentElixir))
      );
      require(transformSuccess, "WorldMineEventSystem: Failed to transform elixir to energy");
    }
    uint256 currentProtein = Protein.get(worldAddress, objectEntityId);
    if (currentProtein > 0) {
      (bool transformSuccess, ) = runSimAction(
        _world(),
        ActionType.Transformation,
        objectEntityId,
        coord,
        SimTable.Energy,
        abi.encode(uint256ToInt256(currentProtein)),
        objectEntityId,
        coord,
        SimTable.Protein,
        abi.encode(uint256ToNegativeInt256(currentProtein))
      );
      require(transformSuccess, "WorldMineEventSystem: Failed to transform protein to energy");
    }
    uint256 currentHealth = Health.getHealth(worldAddress, objectEntityId);
    if (currentHealth > 0) {
      (bool transformSuccess, ) = runSimAction(
        _world(),
        ActionType.Transformation,
        objectEntityId,
        coord,
        SimTable.Energy,
        abi.encode(uint256ToInt256(currentHealth)),
        objectEntityId,
        coord,
        SimTable.Health,
        abi.encode(uint256ToNegativeInt256(currentHealth))
      );
      require(transformSuccess, "WorldMineEventSystem: Failed to transform health to energy");
    }
    uint256 currentStamina = Stamina.get(worldAddress, objectEntityId);
    if (currentStamina > 0) {
      (bool transformSuccess, ) = runSimAction(
        _world(),
        ActionType.Transformation,
        objectEntityId,
        coord,
        SimTable.Energy,
        abi.encode(uint256ToInt256(currentStamina)),
        objectEntityId,
        coord,
        SimTable.Stamina,
        abi.encode(uint256ToNegativeInt256(currentStamina))
      );
      require(transformSuccess, "WorldMineEventSystem: Failed to transform stamina to energy");
    }
    uint256 currentTemperature = Temperature.get(worldAddress, objectEntityId);
    if (currentTemperature > 0) {
      (bool transformSuccess, ) = runSimAction(
        _world(),
        ActionType.Transformation,
        objectEntityId,
        coord,
        SimTable.Energy,
        abi.encode(uint256ToInt256(currentTemperature)),
        objectEntityId,
        coord,
        SimTable.Temperature,
        abi.encode(uint256ToNegativeInt256(currentTemperature))
      );
      require(transformSuccess, "WorldMineEventSystem: Failed to transform temperature to energy");
    }
  }

  function deleteProperties(address worldAddress, bytes32 objectTypeId) internal {
    // Note: we don't delete Mass/Energy/Health because they are required for all objects to exist

    // Energy forms
    if (hasKey(NutrientsTableId, Nutrients.encodeKeyTuple(worldAddress, objectTypeId))) {
      Nutrients.deleteRecord(worldAddress, objectTypeId);
    }
    if (hasKey(ElixirTableId, Elixir.encodeKeyTuple(worldAddress, objectTypeId))) {
      Elixir.deleteRecord(worldAddress, objectTypeId);
    }
    if (hasKey(ProteinTableId, Protein.encodeKeyTuple(worldAddress, objectTypeId))) {
      Protein.deleteRecord(worldAddress, objectTypeId);
    }
    if (hasKey(HealthTableId, Health.encodeKeyTuple(worldAddress, objectTypeId))) {
      Health.deleteRecord(worldAddress, objectTypeId);
    }
    if (hasKey(StaminaTableId, Stamina.encodeKeyTuple(worldAddress, objectTypeId))) {
      Stamina.deleteRecord(worldAddress, objectTypeId);
    }
    if (hasKey(TemperatureTableId, Temperature.encodeKeyTuple(worldAddress, objectTypeId))) {
      Temperature.deleteRecord(worldAddress, objectTypeId);
    }

    // Other properties
    if (hasKey(MetadataTableId, Metadata.encodeKeyTuple(worldAddress, objectTypeId))) {
      Metadata.deleteRecord(worldAddress, objectTypeId);
    }

    if (hasKey(ElementTableId, Element.encodeKeyTuple(worldAddress, objectTypeId))) {
      Element.deleteRecord(worldAddress, objectTypeId);
    }

    if (hasKey(CombatMoveTableId, CombatMove.encodeKeyTuple(worldAddress, objectTypeId))) {
      CombatMove.deleteRecord(worldAddress, objectTypeId);
    }

    if (hasKey(NitrogenTableId, Nitrogen.encodeKeyTuple(worldAddress, objectTypeId))) {
      Nitrogen.deleteRecord(worldAddress, objectTypeId);
    }

    if (hasKey(PhosphorusTableId, Phosphorus.encodeKeyTuple(worldAddress, objectTypeId))) {
      Phosphorus.deleteRecord(worldAddress, objectTypeId);
    }

    if (hasKey(PotassiumTableId, Potassium.encodeKeyTuple(worldAddress, objectTypeId))) {
      Potassium.deleteRecord(worldAddress, objectTypeId);
    }
  }

  function postMineEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public override {
    // IWorld(_world()).resolveCombatMoves();
  }
}
