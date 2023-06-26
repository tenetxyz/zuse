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

// TODO: rename
struct VoxelVariantsKey {
  bytes16 namespace;
  bytes32 voxelVariantId;
}
