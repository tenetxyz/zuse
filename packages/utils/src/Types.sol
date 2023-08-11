// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

struct VoxelCoord {
  int32 x;
  int32 y;
  int32 z;
}

struct Coord {
  int32 x;
  int32 y;
}

struct Tuple {
  int128 x;
  int128 y;
}

enum BlockDirection {
  None,
  North,
  South,
  East,
  West,
  NorthEast,
  NorthWest,
  SouthEast,
  SouthWest,
  Up,
  Down
}

struct BlockHeightUpdate {
  uint256 blockNumber;
  uint256 blockHeightDelta;
  uint256 lastUpdateBlock;
}

struct VoxelTypeData {
  bytes32 voxelTypeId;
  bytes32 voxelVariantId;
}

struct CreationSpawns {
  address worldAddress;
  uint256 numSpawns;
}

struct CreationMetadata {
  address creator;
  string name;
  string description;
  CreationSpawns[] spawns;
}

struct VoxelEntity {
  uint32 scale;
  bytes32 entityId;
}

struct InterfaceVoxel {
  uint256 index;
  VoxelEntity entity;
  string name;
  string desc;
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
