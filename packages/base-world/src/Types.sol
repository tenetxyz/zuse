// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelCoord } from "@tenet-utils/src/Types.sol";

enum EventType {
  Build,
  Mine,
  Activate,
  Move
}

struct MoveEventData {
  VoxelCoord oldCoord;
}
