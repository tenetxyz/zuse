// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { VoxelCoord, Coord, Tuple, BlockDirection } from "@tenet-utils/src/Types.sol";

enum EventType {
  Build,
  Mine,
  Activate
}

struct BuildEventData {
  bytes4 mindSelector;
}

struct ActivateEventData {
  bytes4 interactionSelector;
}

struct MoveEventData {
  VoxelCoord oldCoord;
}