// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { VoxelCoord, Coord, Tuple, BlockDirection } from "@tenet-utils/src/Types.sol";

enum EventType {
  Build,
  Mine,
  Activate
}

struct VoxelEntity {
  uint32 scale;
  bytes32 entityId;
}

struct InterfaceVoxel {
  uint256 index;
  bytes32 entity;
  string name;
  string desc;
}
