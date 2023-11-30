// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

import { WorldMoveEventSystem as WorldMoveEventProtoSystem } from "@tenet-base-simulator/src/systems/WorldMoveEventSystem.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Velocity, VelocityData, VelocityTableId } from "@tenet-simulator/src/codegen/tables/Velocity.sol";

import { abs, absInt32 } from "@tenet-utils/src/MathUtils.sol";
import { getVelocity } from "@tenet-simulator/src/Utils.sol";
import { VoxelCoord, EventType } from "@tenet-utils/src/Types.sol";
import { getEntityIdFromObjectEntityId, getEntityAtCoord } from "@tenet-base-world/src/Utils.sol";

enum MovementResource {
  Stamina,
  Temperature
}

struct EntityData {
  uint256 mass;
  uint256 energy;
  uint256 resource;
}

contract WorldMoveEventSystem is WorldMoveEventProtoSystem {
  function preMoveEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord
  ) public override {
    address worldAddress = _msgSender();
    IWorld(_world()).updateVelocityCache(worldAddress, actingObjectEntityId);
  }

  function onMoveEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bytes32 oldObjectEntityId,
    bytes32 objectEntityId
  ) public override returns (bytes32) {
    address worldAddress = _msgSender();
    if (objectEntityId != actingObjectEntityId) {
      IWorld(_world()).updateVelocityCache(worldAddress, objectEntityId);
    }
    return
      IWorld(_world()).velocityChange(
        worldAddress,
        actingObjectEntityId,
        oldCoord,
        newCoord,
        oldObjectEntityId,
        objectEntityId
      );
  }

  function postMoveEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord,
    bytes32 objectEntityId
  ) public override {
    IWorld(_world()).resolveCombatMoves();
  }
}
