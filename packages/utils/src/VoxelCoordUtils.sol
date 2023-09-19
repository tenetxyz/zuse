// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { int32ToString } from "@tenet-utils/src/StringUtils.sol";
import { NUM_VOXEL_NEIGHBOURS } from "@tenet-utils/src/Constants.sol";

function add(VoxelCoord memory a, VoxelCoord memory b) pure returns (VoxelCoord memory) {
  return VoxelCoord(a.x + b.x, a.y + b.y, a.z + b.z);
}

function sub(VoxelCoord memory a, VoxelCoord memory b) pure returns (VoxelCoord memory) {
  return VoxelCoord(a.x - b.x, a.y - b.y, a.z - b.z);
}

function voxelCoordsAreEqual(VoxelCoord memory c1, VoxelCoord memory c2) pure returns (bool) {
  return c1.x == c2.x && c1.y == c2.y && c1.z == c2.z;
}

function voxelCoordToString(VoxelCoord memory coord) pure returns (string memory) {
  return
    string(
      abi.encodePacked("(", int32ToString(coord.x), ", ", int32ToString(coord.y), ", ", int32ToString(coord.z), ")")
    );
}

// Helper function to get the minimum of two uints
function min(uint a, uint b) pure returns (uint) {
  return a < b ? a : b;
}

function safeSubtract(uint a, uint b) pure returns (uint) {
  if (a > b) {
    return a - b;
  }
  return 0;
}

// Helper function to calculate the absolute value of an integer
function abs(int x) pure returns (int) {
  if (x < 0) {
    return -x;
  }
  return x;
}

function getMooreNeighbours(VoxelCoord memory centerCoord, uint8 neighbourRadius) pure returns (VoxelCoord[] memory) {
  // Moore cube of n x n x
  uint n = 2 * uint(neighbourRadius) + 1;
  // Calculate the number of neighbours
  // (2 * n * n) + (2 * n * (n - 2)) + (2 * (n - 2) * (n - 2))
  uint count = 6 * n * n - 12 * n + 8;

  // Create an array to store the neighbours
  VoxelCoord[] memory neighbours = new VoxelCoord[](count);

  // Index to keep track of array
  uint index = 0;

  int32 iNeighbourRadius = int32(int(uint(neighbourRadius)));

  // Loop through each dimension
  for (int32 i = -iNeighbourRadius; i <= iNeighbourRadius; i++) {
    for (int32 j = -iNeighbourRadius; j <= iNeighbourRadius; j++) {
      for (int32 k = -iNeighbourRadius; k <= iNeighbourRadius; k++) {
        // Ignore the center
        if (i == 0 && j == 0 && k == 0) continue;

        // Ignore inner cube (radius less than neighbourRadius)
        if (abs(i) < iNeighbourRadius && abs(j) < iNeighbourRadius && abs(k) < iNeighbourRadius) continue;

        // This coordinate belongs to the shell, so add it to the array
        neighbours[index] = VoxelCoord(centerCoord.x + i, centerCoord.y + j, centerCoord.z + k);

        // Increment the index
        index++;
      }
    }
  }

  return neighbours;
}

// Using Babylonian method
function sqrt(uint x) pure returns (uint y) {
  uint z = (x + 1) / 2;
  y = x;
  while (z < y) {
    y = z;
    z = (x / z + z) / 2;
  }
}

function distanceBetween(VoxelCoord memory c1, VoxelCoord memory c2) pure returns (uint256) {
  uint32 squaredDistanceX = uint32((c2.x - c1.x) * (c2.x - c1.x));
  uint32 squaredDistanceY = uint32((c2.y - c1.y) * (c2.y - c1.y));
  uint32 squaredDistanceZ = uint32((c2.z - c1.z) * (c2.z - c1.z));
  return sqrt(uint256(squaredDistanceX + squaredDistanceY + squaredDistanceZ));
}

function getNeighbourCoords(VoxelCoord memory coord) pure returns (VoxelCoord[] memory) {
  int8[NUM_VOXEL_NEIGHBOURS * 3] memory NEIGHBOUR_COORD_OFFSETS = [
    int8(0),
    int8(0),
    int8(1),
    // ----
    int8(0),
    int8(0),
    int8(-1),
    // ----
    int8(1),
    int8(0),
    int8(0),
    // ----
    int8(-1),
    int8(0),
    int8(0),
    // ----
    int8(0),
    int8(1),
    int8(0),
    // ----
    int8(0),
    int8(-1),
    int8(0),
    // ----
    int8(1),
    int8(0),
    int8(1),
    // ----
    int8(1),
    int8(0),
    int8(-1),
    // ----
    int8(-1),
    int8(0),
    int8(1),
    // ----
    int8(-1),
    int8(0),
    int8(-1)
  ];

  VoxelCoord[] memory neighbourCoords = new VoxelCoord[](NUM_VOXEL_NEIGHBOURS);

  for (uint8 i = 0; i < NUM_VOXEL_NEIGHBOURS; i++) {
    neighbourCoords[i] = VoxelCoord(
      coord.x + NEIGHBOUR_COORD_OFFSETS[i * 3],
      coord.y + NEIGHBOUR_COORD_OFFSETS[i * 3 + 1],
      coord.z + NEIGHBOUR_COORD_OFFSETS[i * 3 + 2]
    );
  }
  return neighbourCoords;
}

function calculateBlockDirection(
  VoxelCoord memory centerCoord,
  VoxelCoord memory neighborCoord
) pure returns (BlockDirection) {
  if (neighborCoord.x == centerCoord.x && neighborCoord.y == centerCoord.y && neighborCoord.z == centerCoord.z) {
    return BlockDirection.None;
  } else if (neighborCoord.y > centerCoord.y) {
    return BlockDirection.Up;
  } else if (neighborCoord.y < centerCoord.y) {
    return BlockDirection.Down;
  } else if (neighborCoord.z > centerCoord.z) {
    if (neighborCoord.x > centerCoord.x) {
      return BlockDirection.NorthEast;
    } else if (neighborCoord.x < centerCoord.x) {
      return BlockDirection.NorthWest;
    } else {
      return BlockDirection.North;
    }
  } else if (neighborCoord.z < centerCoord.z) {
    if (neighborCoord.x > centerCoord.x) {
      return BlockDirection.SouthEast;
    } else if (neighborCoord.x < centerCoord.x) {
      return BlockDirection.SouthWest;
    } else {
      return BlockDirection.South;
    }
  } else if (neighborCoord.x > centerCoord.x) {
    return BlockDirection.East;
  } else if (neighborCoord.x < centerCoord.x) {
    return BlockDirection.West;
  } else {
    return BlockDirection.None;
  }
}

function getOppositeDirection(BlockDirection direction) pure returns (BlockDirection) {
  if (direction == BlockDirection.None) {
    return BlockDirection.None;
  } else if (direction == BlockDirection.Up) {
    return BlockDirection.Down;
  } else if (direction == BlockDirection.Down) {
    return BlockDirection.Up;
  } else if (direction == BlockDirection.North) {
    return BlockDirection.South;
  } else if (direction == BlockDirection.South) {
    return BlockDirection.North;
  } else if (direction == BlockDirection.East) {
    return BlockDirection.West;
  } else if (direction == BlockDirection.West) {
    return BlockDirection.East;
  } else {
    return BlockDirection.None;
  }
}
