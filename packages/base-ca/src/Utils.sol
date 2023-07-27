// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { BlockDirection } from "@tenet-utils/src/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { CAPosition, CAPositionData, CAPositionTableId } from "@base-ca/src/codegen/Tables.sol";

function getEntityPositionStrict(address callerAddress, bytes32 entity) view returns (CAPositionData memory) {
  require(hasKey(CAPositionTableId, CAPosition.encodeKeyTuple(callerAddress, entity)), "Entity must have a position"); // even if its air, it must have a position
  return CAPosition.get(callerAddress, entity);
}

function calculateBlockDirection(
  CAPositionData memory centerCoord,
  CAPositionData memory neighborCoord
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
