// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";
import { WorldMineEventSystem as WorldMineEventProtoSystem } from "@tenet-base-simulator/src/systems/WorldMineEventSystem.sol";

import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Health, HealthTableId } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Energy, EnergyTableId } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Metadata, MetadataTableId } from "@tenet-simulator/src/codegen/tables/Metadata.sol";

import { VoxelCoord, EventType, ActionType, SimTable } from "@tenet-utils/src/Types.sol";
import { getVelocity } from "@tenet-simulator/src/Utils.sol";
import { isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { uint256ToInt256, uint256ToNegativeInt256 } from "@tenet-utils/src/TypeUtils.sol";
import { runSimAction } from "@tenet-base-simulator/src/CallUtils.sol";

contract WorldMineEventSystem is WorldMineEventProtoSystem {
  function preMineEvent(bytes32 actingObjectEntityId, bytes32 objectTypeId, VoxelCoord memory coord) public override {
    address worldAddress = _msgSender();
    IWorld(_world()).applyHealthIncrease(worldAddress, actingObjectEntityId);
    IWorld(_world()).checkActingObjectHealth(worldAddress, actingObjectEntityId);
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

    IWorld(_world()).applyGravity(worldAddress, coord, objectEntityId, actingObjectEntityId);
  }

  function transformEnergyFormsToGeneralEnergy(
    address worldAddress,
    bytes32 objectEntityId,
    VoxelCoord memory coord
  ) internal {
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
  }

  function deleteProperties(address worldAddress, bytes32 objectTypeId) internal {
    // Note: we don't delete Mass/Energy/Health because they are required for all objects to exist

    // Energy forms
    if (hasKey(HealthTableId, Health.encodeKeyTuple(worldAddress, objectTypeId))) {
      Health.deleteRecord(worldAddress, objectTypeId);
    }
    if (hasKey(StaminaTableId, Stamina.encodeKeyTuple(worldAddress, objectTypeId))) {
      Stamina.deleteRecord(worldAddress, objectTypeId);
    }

    // Other properties
    if (hasKey(MetadataTableId, Metadata.encodeKeyTuple(worldAddress, objectTypeId))) {
      Metadata.deleteRecord(worldAddress, objectTypeId);
    }
  }

  function postMineEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public override {}
}
