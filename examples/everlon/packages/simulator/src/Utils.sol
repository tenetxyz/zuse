// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { Velocity, VelocityData, VelocityTableId } from "@tenet-simulator/src/codegen/tables/Velocity.sol";

function getVelocity(address worldAddress, bytes32 objectEntityId) view returns (VoxelCoord memory) {
  bytes memory velocity = Velocity.getVelocity(worldAddress, objectEntityId);
  return abi.decode(velocity, (VoxelCoord));
}
