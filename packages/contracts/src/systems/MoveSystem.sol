// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "../types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { PlayerPosition, PlayerPositionTableId, Position, PlayerPositionData, PositionTableId, VoxelType, VoxelTypeData, VoxelTypeRegistry } from "../codegen/Tables.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { addressToEntityKey } from "../utils.sol";

contract MoveSystem is System {
  function move(VoxelCoord memory newCoord) public {
    bytes32 playerEntity = addressToEntityKey(_msgSender());
    // check if player has position
    // bytes32[] memory keyTuple = new bytes32[](1);
    // keyTuple[0] = bytes32((playerEntity));
    // require(hasKey(PlayerPositionTableId, keyTuple), "Player does not have position");

    // Get current position of entity
    PlayerPositionData memory currentPosition = PlayerPosition.get(playerEntity);

    // TODO: Add delta logic to check if new position is within bounds

    PlayerPosition.set(playerEntity, PlayerPositionData({ x: newCoord.x, y: newCoord.y, z: newCoord.z }));
  }
}
