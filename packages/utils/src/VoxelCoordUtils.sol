// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
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
      baseCoord.x + NEIGHBOUR_COORD_OFFSETS[i * 3],
      baseCoord.y + NEIGHBOUR_COORD_OFFSETS[i * 3 + 1],
      baseCoord.z + NEIGHBOUR_COORD_OFFSETS[i * 3 + 2]
    );
  }
  return neighbourCoords;
}
