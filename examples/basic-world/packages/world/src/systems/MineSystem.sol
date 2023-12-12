// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

import { SIMULATOR_ADDRESS, AirObjectID } from "@tenet-world/src/Constants.sol";
import { MineSystem as MineProtoSystem } from "@tenet-base-world/src/systems/MineSystem.sol";

contract MineSystem is MineProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function emptyObjectId() internal pure override returns (bytes32) {
    return AirObjectID;
  }

  function mine(
    bytes32 actingObjectEntityId,
    bytes32 mineObjectTypeId,
    VoxelCoord memory mineCoord
  ) public override returns (bytes32) {
    return super.mine(actingObjectEntityId, mineObjectTypeId, mineCoord, new bytes(0));
  }
}
