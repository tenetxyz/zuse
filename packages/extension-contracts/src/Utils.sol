// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { PositionData } from "contracts/src/codegen/Tables.sol";

import {BlockDirection} from "./codegen/Types.sol";

function calculateBlockDirection(PositionData memory centerCoord, PositionData memory neighborCoord)
  pure
  returns (BlockDirection)
{
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