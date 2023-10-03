// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";

function getVelocity(address callerAddress, bytes32 entityId) view returns (VoxelCoord memory) {
  bytes memory velocity = Velocity.getVelocity(callerAddress, entityId);
  return abi.decode(velocity, (VoxelCoord));
}
