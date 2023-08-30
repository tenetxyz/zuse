// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, InteractionSelector } from "@tenet-utils/src/Types.sol";
import { BodyType } from "@tenet-base-ca/src/prototypes/BodyType.sol";

// Represents a agent body
abstract contract AgentType is BodyType {
  // Called by the CA before running the mind to pick a interaction selector
  function onNewNeighbour(bytes32 interactEntity, bytes32 neighbourEntityId) public virtual;

  // Returns the list of actions an agent can have
  function getInteractionSelectors() public virtual returns (InteractionSelector[] memory);
}
