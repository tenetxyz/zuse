// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelCoord, VoxelEntity } from "@tenet-utils/src/Types.sol";
import { SHARD_DIM } from "@tenet-world/src/Constants.sol";
import { floorDiv } from "@tenet-utils/src/MathUtils.sol";

function coordToShardCoord(VoxelCoord memory coord) pure returns (VoxelCoord memory) {
  return
    VoxelCoord({ x: floorDiv(coord.x, SHARD_DIM), y: floorDiv(coord.y, SHARD_DIM), z: floorDiv(coord.z, SHARD_DIM) });
}

function shardCoordToCoord(VoxelCoord memory coord) pure returns (VoxelCoord memory) {
  return VoxelCoord({ x: coord.x * SHARD_DIM, y: coord.y * SHARD_DIM, z: coord.z * SHARD_DIM });
}
