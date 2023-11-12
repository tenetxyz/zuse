// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelCoord } from "@tenet-utils/src/Types.sol";

enum EventType {
  Build,
  Mine,
  Activate,
  Move
}

struct BuildEventData {
  bytes worldData;
}

struct MineEventData {
  bytes worldData;
}

struct ActivateEventData {
  bytes4 interactionSelector;
  bytes worldData;
}

struct MoveEventData {
  VoxelCoord oldCoord;
  bytes worldData;
}
