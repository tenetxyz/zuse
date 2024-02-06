// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { Velocity, VelocityData, VelocityTableId } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { MoveMetadata } from "@tenet-simulator/src/codegen/tables/MoveMetadata.sol";
import { MoveTrigger } from "@tenet-simulator/src/codegen/Types.sol";
import { WORLD_MOVE_SIG } from "@tenet-base-world/src/Constants.sol";

function getVelocity(address worldAddress, bytes32 objectEntityId) view returns (VoxelCoord memory) {
  bytes memory velocity = Velocity.getVelocity(worldAddress, objectEntityId);
  return abi.decode(velocity, (VoxelCoord));
}

function setMoveMetadata(
  address worldAddress,
  bytes32 moveObjectEntityId,
  VoxelCoord memory oldCoord,
  VoxelCoord memory newCoord,
  MoveTrigger moveTrigger
) {
  MoveMetadata.set(
    worldAddress,
    moveObjectEntityId,
    oldCoord.x,
    oldCoord.y,
    oldCoord.z,
    newCoord.x,
    newCoord.y,
    newCoord.z,
    moveTrigger
  );
}

function callWorldMove(
  MoveTrigger moveTrigger,
  address worldAddress,
  bytes32 actingObjectEntityId,
  bytes32 moveObjectEntityId,
  bytes32 moveObjectTypeId,
  VoxelCoord memory oldCoord,
  VoxelCoord memory newCoord
) returns (bool, bytes memory) {
  // If MoveMetadata already exists, eg for gravity, then we don't create a new move trigger
  if (
    MoveMetadata.get(
      worldAddress,
      moveObjectEntityId,
      oldCoord.x,
      oldCoord.y,
      oldCoord.z,
      newCoord.x,
      newCoord.y,
      newCoord.z
    ) != MoveTrigger.None
  ) {
    // TODO: handle existing move trigger, turn the value into an array
    return (false, new bytes(0));
  }
  setMoveMetadata(worldAddress, moveObjectEntityId, oldCoord, newCoord, moveTrigger);

  // Try moving
  // Note: we can't use IMoveSystem here because we need to safe call it
  (bool moveSuccess, bytes memory moveReturnData) = worldAddress.call(
    abi.encodeWithSignature(WORLD_MOVE_SIG, actingObjectEntityId, moveObjectTypeId, oldCoord, newCoord)
  );

  MoveMetadata.deleteRecord(
    worldAddress,
    moveObjectEntityId,
    oldCoord.x,
    oldCoord.y,
    oldCoord.z,
    newCoord.x,
    newCoord.y,
    newCoord.z
  );

  return (moveSuccess, moveReturnData);
}
