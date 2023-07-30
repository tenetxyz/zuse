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
