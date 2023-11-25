// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

abstract contract Constraint is System {
  function transformation(
    bytes32 entityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal virtual;

  function transfer(
    bytes32 senderEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal virtual;
}
