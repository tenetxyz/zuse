// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { WorldMineEventSystem as WorldMineEventProtoSystem } from "@tenet-base-simulator/src/systems/WorldMineEventSystem.sol";

import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";

import { VoxelCoord, EventType } from "@tenet-utils/src/Types.sol";
import { getVelocity } from "@tenet-simulator/src/Utils.sol";
import { isZeroCoord } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { uint256ToInt256 } from "@tenet-utils/src/TypeUtils.sol";

contract WorldMineEventSystem is WorldMineEventProtoSystem {
  function preMineEvent(bytes32 actingObjectEntityId, bytes32 objectTypeId, VoxelCoord memory coord) public override {
    address worldAddress = _msgSender();
    IWorld(_world()).updateVelocityCache(worldAddress, actingObjectEntityId);
  }

  function onMineEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public override {
    address worldAddress = _msgSender();
    if (objectEntityId != actingObjectEntityId) {
      IWorld(_world()).updateVelocityCache(worldAddress, objectEntityId);
    }

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
  }

  function postMineEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public override {
    IWorld(_world()).resolveCombatMoves();
  }
}
