// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, ObjectProperties, Action } from "@tenet-utils/src/Types.sol";

// Represents an object
abstract contract ObjectType is System {
  // Called by Zuse the first time this object is created
  // Returns the properties of this object
  function enterWorld(bytes32 objectEntityId, VoxelCoord memory coord) public virtual returns (ObjectProperties memory);

  // Called by Zuse when this object is destroyed
  function exitWorld(bytes32 objectEntityId, VoxelCoord memory coord) public virtual;

  // Called by Zuse when an event occurs where this object is the center entity
  // Returns the actions it wants to invoke
  function eventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public virtual returns (Action[] memory);

  // Called by Zuse when an event occurs on a center entity and this object is
  // a neighbour entity to it
  // Returns bool to indicate whether an event should be triggered with this object
  // as the center entity
  // Returns the actions it wants to invoke
  function neighbourEventHandler(
    bytes32 neighbourObjectEntityId,
    bytes32 centerObjectEntityId
  ) public virtual returns (bool, Action[] memory);
}
