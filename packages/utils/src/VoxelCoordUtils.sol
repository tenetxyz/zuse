// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelCoord, BlockDirection } from "@tenet-utils/src/Types.sol";
import { int32ToString } from "@tenet-utils/src/StringUtils.sol";
import { min, abs, sqrt, floorDiv } from "@tenet-utils/src/MathUtils.sol";

function add(VoxelCoord memory a, VoxelCoord memory b) pure returns (VoxelCoord memory) {
  return VoxelCoord(a.x + b.x, a.y + b.y, a.z + b.z);
}

function sub(VoxelCoord memory a, VoxelCoord memory b) pure returns (VoxelCoord memory) {
  return VoxelCoord(a.x - b.x, a.y - b.y, a.z - b.z);
}

function dot(VoxelCoord memory a, VoxelCoord memory b) pure returns (int) {
  return a.x * b.x + a.y * b.y + a.z * b.z;
}

function mulScalar(VoxelCoord memory a, int32 factor) pure returns (VoxelCoord memory) {
  return VoxelCoord(a.x * factor, a.y * factor, a.z * factor);
}

function divScalar(VoxelCoord memory a, int32 factor) pure returns (VoxelCoord memory) {
  return VoxelCoord(a.x / factor, a.y / factor, a.z / factor);
}

function voxelCoordsAreEqual(VoxelCoord memory c1, VoxelCoord memory c2) pure returns (bool) {
  return c1.x == c2.x && c1.y == c2.y && c1.z == c2.z;
}

function isZeroCoord(VoxelCoord memory coord) pure returns (bool) {
  return coord.x == 0 && coord.y == 0 && coord.z == 0;
}

function voxelCoordToString(VoxelCoord memory coord) pure returns (string memory) {
  return
    string(
      abi.encodePacked("(", int32ToString(coord.x), ", ", int32ToString(coord.y), ", ", int32ToString(coord.z), ")")
    );
}

function coordToShardCoord(VoxelCoord memory coord, int32 SHARD_DIM) pure returns (VoxelCoord memory) {
  return
    VoxelCoord({ x: floorDiv(coord.x, SHARD_DIM), y: floorDiv(coord.y, SHARD_DIM), z: floorDiv(coord.z, SHARD_DIM) });
}

function shardCoordToCoord(VoxelCoord memory coord, int32 SHARD_DIM) pure returns (VoxelCoord memory) {
  return VoxelCoord({ x: coord.x * SHARD_DIM, y: coord.y * SHARD_DIM, z: coord.z * SHARD_DIM });
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

function distanceBetween(VoxelCoord memory c1, VoxelCoord memory c2) pure returns (uint256) {
  uint32 squaredDistanceX = uint32((c2.x - c1.x) * (c2.x - c1.x));
  uint32 squaredDistanceY = uint32((c2.y - c1.y) * (c2.y - c1.y));
  uint32 squaredDistanceZ = uint32((c2.z - c1.z) * (c2.z - c1.z));
  return sqrt(uint256(squaredDistanceX + squaredDistanceY + squaredDistanceZ));
}

function inSurroundingCube(
  VoxelCoord memory cubeCenter,
  int32 halfWidth,
  VoxelCoord memory checkCoord
) pure returns (bool) {
  // Check if `checkCoord` is within the cube in all three dimensions
  bool isInX = checkCoord.x >= cubeCenter.x - halfWidth && checkCoord.x <= cubeCenter.x + halfWidth;
  bool isInY = checkCoord.y >= cubeCenter.y - halfWidth && checkCoord.y <= cubeCenter.y + halfWidth;
  bool isInZ = checkCoord.z >= cubeCenter.z - halfWidth && checkCoord.z <= cubeCenter.z + halfWidth;

  return isInX && isInY && isInZ;
}

function getVonNeumannNeighbours(VoxelCoord memory centerCoord) pure returns (VoxelCoord[] memory) {
  // In 3D, there are 6 von Neumann neighbours
  uint8 numNeighbours = 6;
  VoxelCoord[] memory neighbourCoords = new VoxelCoord[](numNeighbours);

  for (int8 dx = -1; dx <= 1; dx++) {
    for (int8 dy = -1; dy <= 1; dy++) {
      for (int8 dz = -1; dz <= 1; dz++) {
        if ((dx == 0 && dy == 0 && dz != 0) || (dx == 0 && dy != 0 && dz == 0) || (dx != 0 && dy == 0 && dz == 0)) {
          neighbourCoords[numNeighbours - 1] = VoxelCoord(centerCoord.x + dx, centerCoord.y + dy, centerCoord.z + dz);
          numNeighbours--;
        }
      }
    }
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
    return BlockDirection.North;
  } else if (neighborCoord.z < centerCoord.z) {
    return BlockDirection.South;
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
