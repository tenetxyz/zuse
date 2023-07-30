// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getCallerNamespace } from "@tenet-utils/src/Utils.sol";
import { calculateBlockDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { BlockDirection, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";

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
    BlockDirection[] memory neighbourEntityDirections,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal virtual returns (bool changedEntity);

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view virtual returns (bool);

  function runCaseOne(
    address callerAddress,
    bytes32 centerEntityId,
    VoxelCoord memory centerPosition,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal returns (bytes32) {
    bytes32 changedCenterEntityId = 0;
    if (entityShouldInteract(callerAddress, centerEntityId)) {
      BlockDirection[] memory neighbourEntityDirections = new BlockDirection[](neighbourEntityIds.length);
      for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
        bytes32 neighbourEntityId = neighbourEntityIds[i];
        if (uint256(neighbourEntityId) == 0) {
          neighbourEntityDirections[i] = BlockDirection.None;
          continue;
        }

        BlockDirection centerBlockDirection = calculateBlockDirection(
          getEntityPositionStrict(IStore(_world()), callerAddress, neighbourEntityId),
          centerPosition
        );
        neighbourEntityDirections[i] = centerBlockDirection;
      }
      bool changedEntity = runInteraction(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        neighbourEntityDirections,
        childEntityIds,
        parentEntity
      );
      if (changedEntity) {
        changedCenterEntityId = centerEntityId;
      }
    }

    return changedCenterEntityId;
  }

  function runCaseTwo(
    address callerAddress,
    bytes32 centerEntityId,
    VoxelCoord memory centerPosition,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal returns (bytes32[] memory) {
    bytes32[] memory changedEntityIds = new bytes32[](neighbourEntityIds.length);
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];

      if (uint256(neighbourEntityId) == 0 || !entityShouldInteract(callerAddress, neighbourEntityId)) {
        changedEntityIds[i] = 0;
        continue;
      }

      BlockDirection centerBlockDirection = calculateBlockDirection(
        centerPosition,
        getEntityPositionStrict(IStore(_world()), callerAddress, neighbourEntityId)
      );

      bool changedEntity = onNewNeighbour(callerAddress, neighbourEntityId, centerEntityId, centerBlockDirection);

      if (changedEntity) {
        changedEntityIds[i] = neighbourEntityId;
      } else {
        changedEntityIds[i] = 0;
      }
    }
    return changedEntityIds;
  }

  function eventHandler(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {
    VoxelCoord memory centerPosition = getEntityPositionStrict(IStore(_world()), callerAddress, centerEntityId);

    // case one: center is the entity we care about, check neighbours to see if things need to change
    bytes32 changedCenterEntityId = runCaseOne(
      callerAddress,
      centerEntityId,
      centerPosition,
      neighbourEntityIds,
      childEntityIds,
      parentEntity
    );

    // case two: neighbour is the entity we care about, check center to see if things need to change
    bytes32[] memory changedEntityIds = runCaseTwo(
      callerAddress,
      centerEntityId,
      centerPosition,
      neighbourEntityIds,
      childEntityIds,
      parentEntity
    );

    return (changedCenterEntityId, changedEntityIds);
  }
}
