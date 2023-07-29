// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

// Represents a voxel (or Minecraft block)
abstract contract VoxelType is System {
  // Called once to register the voxel into the CA
  function registerVoxel() public virtual;

  // Called by the CA every time the voxel is placed in the world
  function enterWorld(bytes32 entity) public virtual;

  // Called by the CA every time the voxel is removed from the world
  function exitWorld(bytes32 entity) public virtual;

  // Called by the CA to determine which variant (or graphic) of the voxel to use
  function variantSelector(bytes32 entity) public view virtual returns (bytes32 voxelVariantId);
}
