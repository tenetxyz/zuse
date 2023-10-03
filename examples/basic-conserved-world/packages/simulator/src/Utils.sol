// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { BodyPhysics, BodyPhysicsData } from "@tenet-world/src/codegen/tables/BodyPhysics.sol";
import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";

function getVelocity(VoxelEntity memory entity) view returns (VoxelCoord memory) {
  bytes memory velocity = BodyPhysics.getVelocity(entity.scale, entity.entityId);
  return abi.decode(velocity, (VoxelCoord));
}
