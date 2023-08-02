// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";

// Represents a voxel (or Minecraft block)
abstract contract VoxelType is System {
  // Called once to register the voxel into the CA
  function registerVoxel() public virtual;

  // Called by the CA every time the voxel is placed in the world
  function enterWorld(VoxelCoord memory coord, bytes32 entity) public virtual;

  // Called by the CA every time the voxel is removed from the world
  function exitWorld(VoxelCoord memory coord, bytes32 entity) public virtual;

  // Called by the CA to determine which variant (or graphic) of the voxel to use
  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view virtual returns (bytes32 voxelVariantId);

  // Called by the CA when the player right clicks it
  function activate(bytes32 entity) public view virtual returns (string memory);

  // Called by the CA when an event occurs that includes the voxel
  // the voxel could either be the center or a neighbour
  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public virtual returns (bytes32, bytes32[] memory);
}
