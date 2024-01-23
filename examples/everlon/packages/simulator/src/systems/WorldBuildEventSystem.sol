// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { WorldBuildEventSystem as WorldBuildEventProtoSystem } from "@tenet-base-simulator/src/systems/WorldBuildEventSystem.sol";

import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Nitrogen, NitrogenTableId } from "@tenet-simulator/src/codegen/tables/Nitrogen.sol";
import { Phosphorus, PhosphorusTableId } from "@tenet-simulator/src/codegen/tables/Phosphorus.sol";
import { Potassium, PotassiumTableId } from "@tenet-simulator/src/codegen/tables/Potassium.sol";
import { Element, ElementTableId } from "@tenet-simulator/src/codegen/tables/Element.sol";

import { VoxelCoord, EventType, ObjectProperties, ElementType } from "@tenet-utils/src/Types.sol";
import { NUM_MAX_INIT_NPK } from "@tenet-simulator/src/Constants.sol";

contract WorldBuildEventSystem is WorldBuildEventProtoSystem {
  function preBuildEvent(bytes32 actingObjectEntityId, bytes32 objectTypeId, VoxelCoord memory coord) public override {
    // address worldAddress = _msgSender();
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

    if (objectProperties.elementType != ElementType.None) {
      require(
        Element.get(worldAddress, objectEntityId) == ElementType.None,
        "WorldBuildEventSystem: Element type already set"
      );
      Element.set(worldAddress, objectEntityId, objectProperties.elementType);
    }

    if (objectProperties.nitrogen > 0) {
      require(
        !hasKey(NitrogenTableId, Nitrogen.encodeKeyTuple(worldAddress, objectEntityId)),
        "WorldBuildEventSystem: Nitrogen for object already initialized"
      );
      Nitrogen.set(worldAddress, objectEntityId, objectProperties.nitrogen);
    }
    if (objectProperties.phosphorus > 0) {
      require(
        !hasKey(PhosphorusTableId, Phosphorus.encodeKeyTuple(worldAddress, objectEntityId)),
        "WorldBuildEventSystem: Phosphorus for object already initialized"
      );
      Phosphorus.set(worldAddress, objectEntityId, objectProperties.phosphorus);
    }
    if (objectProperties.potassium > 0) {
      require(
        !hasKey(PotassiumTableId, Potassium.encodeKeyTuple(worldAddress, objectEntityId)),
        "WorldBuildEventSystem: Potassium for object already initialized"
      );
      Potassium.set(worldAddress, objectEntityId, objectProperties.potassium);
    }

    require(
      objectProperties.nitrogen + objectProperties.phosphorus + objectProperties.potassium <= NUM_MAX_INIT_NPK,
      "WorldBuildEventSystem: NPK must be less than or equal to the initial NPK constant"
    );

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

    // IWorld(_world()).applyTemperatureEffects(worldAddress, objectEntityId);
  }

  function postBuildEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public override {
    // IWorld(_world()).resolveCombatMoves();
  }
}
