// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelCoord, ObjectProperties, Action, ActionType, SimTable } from "@tenet-utils/src/Types.sol";
import { uint256ToInt256 } from "@tenet-utils/src/TypeUtils.sol";

function tryStoppingAction(
  bytes32 objectEntityId,
  VoxelCoord memory coord,
  ObjectProperties memory entityProperties
) pure returns (bool, Action memory stopAction) {
  VoxelCoord memory velocity = abi.decode(entityProperties.velocity, (VoxelCoord));
  if (velocity.x == 0 && velocity.y == 0 && velocity.z == 0) {
    return (false, stopAction);
  }

  // Decrease velocity to 0
  uint256 transferStamina = 0; // TODO: calculate and don't send event if we dont have enough stamina
  VoxelCoord memory deltaVelocity = VoxelCoord({
    x: velocity.x > 0 ? -velocity.x : velocity.x,
    y: velocity.y > 0 ? -velocity.y : velocity.y,
    z: velocity.z > 0 ? -velocity.z : velocity.z
  });
  stopAction = Action({
    actionType: ActionType.Transformation,
    senderTable: SimTable.Stamina,
    senderValue: abi.encode(uint256ToInt256(transferStamina)),
    targetObjectEntityId: objectEntityId,
    targetCoord: coord,
    targetTable: SimTable.Velocity,
    targetValue: abi.encode(deltaVelocity)
  });
  return (true, stopAction);
}
