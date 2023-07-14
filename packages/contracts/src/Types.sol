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

struct BaseCreation {
  bytes32 creationId;
  VoxelCoord coordOffset; // the offset of the base creation relative to the creation this base creation is in
  // To get the real coords of each voxel in this base creation, add this offset to the relative coord of the voxel

  VoxelCoord[] deletedRelativeCoords; // the coord relative to this BASE creation, not to the creation this base creation is in
}
