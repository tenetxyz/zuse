// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, EventType, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { WorldBuildEventSystem as WorldBuildEventProtoSystem } from "@tenet-base-simulator/src/systems/WorldBuildEventSystem.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";

contract WorldBuildEventSystem is WorldBuildEventProtoSystem {
  function preBuildEvent(bytes32 actingObjectEntityId, bytes32 objectTypeId, VoxelCoord memory coord) public override {}

  function onBuildEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId,
    ObjectProperties memory objectProperties
  ) public override {
    address world = _msgSender();

    // address callerAddress = _msgSender();
    // preEvent(callerAddress, actingEntity);
    // bool entityExists = hasKey(MassTableId, Mass.encodeKeyTuple(callerAddress, entity.scale, entity.entityId));
    // require(entityMass > 0, "Mass must be greater than zero to build");
    // if (entityExists) {
    //   uint256 currentMass = Mass.get(callerAddress, entity.scale, entity.entityId);
    //   require(currentMass == 0, "Mass must be zero to build");
    // } else {
    //   uint256 terrainMass = getTerrainMass(callerAddress, entity.scale, coord);
    //   require(terrainMass == 0 || terrainMass == entityMass, "Invalid terrain mass");

    //   // Set initial values
    //   Mass.set(callerAddress, entity.scale, entity.entityId, 0); // Set to zero to prevent double build
    //   Energy.set(callerAddress, entity.scale, entity.entityId, getTerrainEnergy(callerAddress, entity.scale, coord));
    //   Velocity.set(
    //     callerAddress,
    //     entity.scale,
    //     entity.entityId,
    //     block.number,
    //     abi.encode(getTerrainVelocity(callerAddress, entity.scale, coord))
    //   );
    // }

    // int256 massDelta = uint256ToInt256(entityMass);
    // IWorld(_world()).updateMass(entity, coord, massDelta, entity, coord, massDelta);

    // IWorld(_world()).temperatureBehaviour(callerAddress, entity);
  }

  function postBuildEvent(
    bytes32 actingObjectEntityId,
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public override {}
}
