// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

struct MoveEventData {
  VoxelCoord oldCoord;
}

struct TerrainData {
  bytes32 objectTypeId;
  ObjectProperties properties;
}

struct TerrainSectionData {
  bool useExistingObjectTypeId;
  bytes32 objectTypeId;
  uint256 energy;
  uint256 mass;
  int32 xCorner;
  int32 yCorner;
  int32 zCorner;
  int32 xLength;
  int32 zLength;
  int32 yLength;
  bool includeAir;
}
