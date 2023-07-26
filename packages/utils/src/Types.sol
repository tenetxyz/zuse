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
  Up,
  Down,
  North,
  South,
  East,
  West
}