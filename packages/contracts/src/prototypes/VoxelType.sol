// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";

abstract contract VoxelType is System {
  function registerVoxel() public virtual;
}
