// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { VoxelCoord } from "@latticexyz/std-contracts/src/components/VoxelCoordComponent.sol";

struct Coord {
  int32 x;
  int32 y;
}

struct Tuple {
  int128 x;
  int128 y;
}

struct VoxelVariantsKey {
  bytes16 voxelVariantNamespace;
  bytes32 voxelVariantId;
}

enum BlockDirection {
  None,
  Up,
  Down,
  North,
  South,
  East,
  West
}

struct InterfaceVoxel {
  uint256 index;
  bytes32 entity;
  string name;
  string desc;
}
