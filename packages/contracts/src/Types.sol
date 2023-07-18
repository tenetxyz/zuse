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

// TODO: rename to just direction?
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

struct BlockHeightUpdate {
  uint256 blockNumber;
  uint256 blockHeightDelta;
  uint256 lastUpdateBlock;
}

struct BaseCreationInWorld {
  bytes32 creationId;
  VoxelCoord lowerSouthWestCornerInWorld;
  VoxelCoord[] deletedRelativeCoords; // the coord relative to the BASE creation, not to the creation this base creation is in
}

struct BaseCreation {
  bytes32 creationId;
  VoxelCoord coordOffset; // the offset of the base creation relative to the creation this base creation is in
  // To get the real coords of each voxel in this base creation, add this offset to the relative coord of each voxel

  VoxelCoord[] deletedRelativeCoords; // the coord relative to this BASE creation, not to the creation this base creation is in
  // Why store deleted coords? Cause it's more space-efficient to store the deleted coords than all the voxels in the creation
  // Also in the future, this could be a "diffs" array.
}
