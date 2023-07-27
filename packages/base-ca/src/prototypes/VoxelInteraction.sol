// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { CAPositionData } from "@base-ca/src/codegen/Tables.sol";
import { getCallerNamespace } from "@tenet-utils/src/Utils.sol";
import { BlockDirection } from "@tenet-utils/src/Types.sol";
import { getEntityPositionStrict, calculateBlockDirection } from "@base-ca/src/Utils.sol";

abstract contract VoxelInteraction is System {
  function onNewNeighbour(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal virtual returns (bool changedEntity);

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections
  ) internal virtual returns (bool changedEntity);

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view virtual returns (bool);

  function eventHandler(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public returns (bytes32, bytes32[] memory) {
    bytes32 changedCenterEntityId = 0;
    bytes32[] memory changedEntityIds = new bytes32[](neighbourEntityIds.length);

    CAPositionData memory centerPosition = getEntityPositionStrict(callerAddress, centerEntityId);

    // case one: center is the entity we care about, check neighbours to see if things need to change
    if (entityShouldInteract(callerAddress, centerEntityId)) {
      BlockDirection[] memory neighbourEntityDirections = new BlockDirection[](neighbourEntityIds.length);
      for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
        bytes32 neighbourEntityId = neighbourEntityIds[i];
        if (uint256(neighbourEntityId) == 0) {
          neighbourEntityDirections[i] = BlockDirection.None;
          continue;
        }

        BlockDirection centerBlockDirection = calculateBlockDirection(
          getEntityPositionStrict(callerAddress, neighbourEntityId),
          centerPosition
        );
        neighbourEntityDirections[i] = centerBlockDirection;
      }
      bool changedEntity = runInteraction(callerAddress, centerEntityId, neighbourEntityIds, neighbourEntityDirections);
      if (changedEntity) {
        changedCenterEntityId = centerEntityId;
      }
    }

    // case two: neighbour is the entity we care about, check center to see if things need to change
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];

      if (uint256(neighbourEntityId) == 0 || !entityShouldInteract(callerAddress, neighbourEntityId)) {
        changedEntityIds[i] = 0;
        continue;
      }

      BlockDirection centerBlockDirection = calculateBlockDirection(
        centerPosition,
        getEntityPositionStrict(callerAddress, neighbourEntityId)
      );

      bool changedEntity = onNewNeighbour(callerAddress, neighbourEntityId, centerEntityId, centerBlockDirection);

      if (changedEntity) {
        changedEntityIds[i] = neighbourEntityId;
      } else {
        changedEntityIds[i] = 0;
      }
    }

    return (changedCenterEntityId, changedEntityIds);
  }
}
