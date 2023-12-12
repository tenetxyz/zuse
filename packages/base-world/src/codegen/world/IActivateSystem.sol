// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { VoxelCoord } from "@tenet-utils/src/Types.sol";

interface IActivateSystem {
  function activate(
    bytes32 actingObjectEntityId,
    bytes32 activateObjectTypeId,
    VoxelCoord memory activateCoord
  ) external returns (bytes32);
}
