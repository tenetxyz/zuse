// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { Mind } from "@tenet-utils/src/Types.sol";

interface IMindRegistrySystem {
  function registerMind(bytes32 voxelTypeId, Mind memory mind) external;

  function registerMindForWorld(bytes32 voxelTypeId, address worldAddress, Mind memory mind) external;
}
