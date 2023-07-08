// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { VoxelVariantsKey } from "../Types.sol";

// Represents a voxel (or Minecraft block)
abstract contract VoxelType is System {
  // Called once to register the voxel into the world
  function registerVoxel() public virtual;

  // Called by the world every time the voxel is placed in the world
  function enterWorld(bytes32 entity) public virtual;

  // Called by the world every time the voxel is removed from the world
  function exitWorld(bytes32 entity) public virtual;

  // Called by the world to determine which variant (or graphic) of the voxel to use
  function variantSelector(bytes32 entity) public view virtual returns (VoxelVariantsKey memory);
}
