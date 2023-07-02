// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { Position, PositionData, PositionTableId } from "@tenetxyz/contracts/src/codegen/tables/Position.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SignalTableId, SignalSourceTableId, PoweredTableId, InvertedSignalTableId } from "./codegen/Tables.sol";
import { BlockDirection } from "./codegen/types.sol";

function entityIsSignal(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
  bytes32[] memory keyTuple = new bytes32[](2);
  keyTuple[0] = bytes32((callerNamespace));
  keyTuple[1] = bytes32((entity));
  return hasKey(SignalTableId, keyTuple);
}

function entityIsSignalSource(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
  bytes32[] memory keyTuple = new bytes32[](2);
  keyTuple[0] = bytes32((callerNamespace));
  keyTuple[1] = bytes32((entity));
  return hasKey(SignalSourceTableId, keyTuple);
}

function entityIsPowered(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
  bytes32[] memory keyTuple = new bytes32[](2);
  keyTuple[0] = bytes32((callerNamespace));
  keyTuple[1] = bytes32((entity));
  return hasKey(PoweredTableId, keyTuple);
}

function entityIsInvertedSignal(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
  bytes32[] memory keyTuple = new bytes32[](2);
  keyTuple[0] = bytes32((callerNamespace));
  keyTuple[1] = bytes32((entity));
  return hasKey(InvertedSignalTableId, keyTuple);
}

function getEntityPositionStrict(bytes32 entity) view returns (PositionData memory) {
  bytes32[] memory positionKeyTuple = new bytes32[](1);
  positionKeyTuple[0] = bytes32((entity));
  require(hasKey(PositionTableId, positionKeyTuple), "Entity must have a position"); // even if its air, it must have a position
  return Position.get(entity);
}

function calculateBlockDirection(
  PositionData memory centerCoord,
  PositionData memory neighborCoord
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

function getOppositeDirection(BlockDirection direction) pure returns (BlockDirection) {
  if (direction == BlockDirection.None) {
    return BlockDirection.None;
  } else if (direction == BlockDirection.Up) {
    return BlockDirection.Down;
  } else if (direction == BlockDirection.Down) {
    return BlockDirection.Up;
  } else if (direction == BlockDirection.North) {
    return BlockDirection.South;
  } else if (direction == BlockDirection.South) {
    return BlockDirection.North;
  } else if (direction == BlockDirection.East) {
    return BlockDirection.West;
  } else if (direction == BlockDirection.West) {
    return BlockDirection.East;
  } else {
    return BlockDirection.None;
  }
}
