// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

import { SIMULATOR_ADDRESS, AirObjectID } from "@tenet-world/src/Constants.sol";
import { MoveSystem as MoveProtoSystem } from "@tenet-base-world/src/systems/MoveSystem.sol";
import { MoveEventData } from "@tenet-world/src/Types.sol";

contract MoveSystem is MoveProtoSystem {
  function getOldCoord(bytes memory eventData) internal pure override returns (VoxelCoord memory) {
    MoveEventData memory moveEventData = abi.decode(eventData, (MoveEventData));
    return moveEventData.oldCoord;
  }

  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function emptyObjectId() internal pure override returns (bytes32) {
    return AirObjectID;
  }

  function move(
    bytes32 actingObjectEntityId,
    bytes32 moveObjectTypeId,
    VoxelCoord memory oldCoord,
    VoxelCoord memory newCoord
  ) public override returns (bytes32, bytes32) {
    MoveEventData memory moveEventData = MoveEventData({ oldCoord: oldCoord });
    return super.move(actingObjectEntityId, moveObjectTypeId, newCoord, moveEventData);
  }
}
