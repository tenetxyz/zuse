// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelCoord } from "@tenet-utils/src/Types.sol";

struct BuildEventData {
  bytes32 inventoryId;
}

struct MoveEventData {
  VoxelCoord oldCoord;
}
