// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { MineEvent } from "@tenet-base-world/src/prototypes/MineEvent.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

abstract contract MineSystem is MineEvent {
  function mine(
    bytes32 actingObjectEntityId,
    bytes32 mineObjectTypeId,
    VoxelCoord memory mineCoord
  ) public virtual returns (bytes32);
}
