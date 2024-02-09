// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/haskeys/hasKey.sol";
import { WorldBuildEventSystem as WorldBuildEventProtoSystem } from "@tenet-base-simulator/src/systems/WorldBuildEventSystem.sol";

import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Stamina, StaminaTableId } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { VoxelCoord, EventType, ObjectProperties, ElementType } from "@tenet-utils/src/Types.sol";

contract WorldBuildEventSystem is WorldBuildEventProtoSystem {
  function preBuildEvent(bytes32 actingObjectEntityId, bytes32 objectTypeId, VoxelCoord memory coord) public override {
    address worldAddress = _msgSender();
    IWorld(_world()).applyHealthIncrease(worldAddress, actingObjectEntityId);
    IWorld(_world()).applyStaminaIncrease(worldAddress, actingObjectEntityId);
    // IWorld(_world()).checkActingObjectHealth(worldAddress, actingObjectEntityId);
    // IWorld(_world()).updateVelocityCache(worldAddress, actingObjectEntityId);
  }

  function onBuildEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId,
    ObjectProperties memory objectProperties,
    bool isNewEntity
  ) public override {
    address worldAddress = _msgSender();
    // if (objectEntityId != actingObjectEntityId) {
    //   IWorld(_world()).updateVelocityCache(worldAddress, objectEntityId);
    // }

    require(
      hasKey(MassTableId, Mass.encodeKeyTuple(worldAddress, objectEntityId)),
      "WorldBuildEventSystem: Entity is not initialized"
    );
    uint256 currentMass = Mass.get(worldAddress, objectEntityId);
    if (isNewEntity) {
      require(currentMass == 0 || currentMass == objectProperties.mass, "WorldBuildEventSystem: Invalid terrain mass");
    } else {
      require(currentMass == 0, "WorldBuildEventSystem: Mass must be zero to build");
    }

    IWorld(_world()).massTransformation(
      objectEntityId,
      coord,
      abi.encode(currentMass),
      abi.encode(objectProperties.mass - currentMass)
    );

    if (actingObjectEntityId != bytes32(0)) {
      uint256 currentResourceAmount = Stamina.getStamina(worldAddress, actingObjectEntityId);
      uint256 resourceRequired = (objectProperties.mass - currentMass) * 10;
      require(resourceRequired <= currentResourceAmount, "WorldBuildEventSystem: Not enough resources to build.");
      Stamina.setStamina(worldAddress, actingObjectEntityId, currentResourceAmount - resourceRequired);
    }

    IWorld(_world()).applyGravity(worldAddress, coord, objectEntityId, actingObjectEntityId);
  }

  function postBuildEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public override {}
}
