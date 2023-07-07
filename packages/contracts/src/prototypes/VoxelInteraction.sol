// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";

import { PositionData } from "../codegen/tables/Position.sol";
import { getCallerNamespace } from "../SharedUtils.sol";
import { BlockDirection } from "../Types.sol";
import { calculateBlockDirection, getEntityPositionStrict } from "../Utils.sol";

abstract contract VoxelInteraction is System {
  function registerVoxelInteraction() public virtual;

  function runInteraction(
    bytes16 callerNamespace,
    bytes32 interactEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal virtual returns (bool changedEntity);

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view virtual returns (bool);

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public virtual returns (bytes32[] memory) {
    bytes32[] memory changedEntityIds = new bytes32[](neighbourEntityIds.length);
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    // TODO: require not root namespace

    PositionData memory centerPosition = getEntityPositionStrict(centerEntityId);

    // case one: center is the entity we care about, check neighbours to see if things need to change
    if (entityShouldInteract(centerEntityId, callerNamespace)) {
      for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
        bytes32 neighbourEntityId = neighbourEntityIds[i];
        if (uint256(neighbourEntityId) == 0) {
          continue;
        }

        BlockDirection centerBlockDirection = calculateBlockDirection(
          getEntityPositionStrict(neighbourEntityId),
          centerPosition
        );
        runInteraction(callerNamespace, centerEntityId, neighbourEntityId, centerBlockDirection);
      }
    }

    // case two: neighbour is the entity we care about, check center to see if things need to change
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];

      if (uint256(neighbourEntityId) == 0 || !entityShouldInteract(neighbourEntityId, callerNamespace)) {
        changedEntityIds[i] = 0;
        continue;
      }

      BlockDirection centerBlockDirection = calculateBlockDirection(
        centerPosition,
        getEntityPositionStrict(neighbourEntityId)
      );

      bool changedEntity = runInteraction(callerNamespace, neighbourEntityId, centerEntityId, centerBlockDirection);

      if (changedEntity) {
        changedEntityIds[i] = neighbourEntityId;
      } else {
        changedEntityIds[i] = 0;
      }
    }

    return changedEntityIds;
  }
}
