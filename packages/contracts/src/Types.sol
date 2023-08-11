// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { VoxelCoord, Coord, Tuple, BlockDirection } from "@tenet-utils/src/Types.sol";

enum EventType {
  Build,
  Mine,
  Activate
}
