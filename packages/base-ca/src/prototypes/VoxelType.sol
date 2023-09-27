// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";
import { BodyType } from "@tenet-base-ca/src/prototypes/BodyType.sol";

// Represents a voxel body (or Minecraft block)
abstract contract VoxelType is BodyType {
  // Called by the CA when an event occurs where this voxel
  // is the center entity
  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public virtual returns (bool, bytes memory);
}
