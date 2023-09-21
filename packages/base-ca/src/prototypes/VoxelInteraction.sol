// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { calculateBlockDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { BlockDirection, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getCAEntityPositionStrict } from "@tenet-base-ca/src/Utils.sol";

abstract contract VoxelInteraction is System {
  function onNewNeighbour(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal virtual returns (bool changedEntity, bytes memory entityData);

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal virtual returns (bool changedEntity, bytes memory entityData);

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view virtual returns (bool);

  function runCaseOne(
    address callerAddress,
    bytes32 centerEntityId,
    VoxelCoord memory centerPosition,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal returns (bytes32, bytes memory) {
    bytes32 changedCenterEntityId = 0;
    bytes memory centerEntityData;
    if (entityShouldInteract(callerAddress, centerEntityId)) {
      BlockDirection[] memory neighbourEntityDirections = new BlockDirection[](neighbourEntityIds.length);
      for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
        bytes32 neighbourEntityId = neighbourEntityIds[i];
        if (uint256(neighbourEntityId) == 0) {
          neighbourEntityDirections[i] = BlockDirection.None;
          continue;
        }

        BlockDirection centerBlockDirection = calculateBlockDirection(
          getCAEntityPositionStrict(IStore(_world()), neighbourEntityId),
          centerPosition
        );
        neighbourEntityDirections[i] = centerBlockDirection;
      }
      (bool changedEntity, bytes memory entityData) = runInteraction(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        neighbourEntityDirections,
        childEntityIds,
        parentEntity
      );
      centerEntityData = entityData;
      if (changedEntity) {
        changedCenterEntityId = centerEntityId;
      }
    }

    return (changedCenterEntityId, centerEntityData);
  }

  function onNewNeighbourWrapper(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId,
    VoxelCoord memory centerPosition
  ) internal returns (bool, bytes memory) {
    BlockDirection centerBlockDirection = calculateBlockDirection(
      centerPosition,
      getCAEntityPositionStrict(IStore(_world()), neighbourEntityId)
    );

    return onNewNeighbour(callerAddress, neighbourEntityId, centerEntityId, centerBlockDirection);
  }

  function runCaseTwo(
    address callerAddress,
    bytes32 centerEntityId,
    VoxelCoord memory centerPosition,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal returns (bytes32[] memory, bytes[] memory) {
    bytes32[] memory changedEntityIds = new bytes32[](neighbourEntityIds.length);
    bytes[] memory neighbourEntitiesData = new bytes[](neighbourEntityIds.length);
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];

      if (uint256(neighbourEntityId) == 0 || !entityShouldInteract(callerAddress, neighbourEntityId)) {
        changedEntityIds[i] = 0;
        continue;
      }

      (bool changedEntity, bytes memory entityData) = onNewNeighbourWrapper(
        callerAddress,
        neighbourEntityId,
        centerEntityId,
        centerPosition
      );
      neighbourEntitiesData[i] = entityData;

      if (changedEntity) {
        changedEntityIds[i] = neighbourEntityId;
      } else {
        changedEntityIds[i] = 0;
      }
    }
    return (changedEntityIds, neighbourEntitiesData);
  }

  function eventHandler(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal returns (bytes32, bytes32[] memory, bytes[] memory) {
    VoxelCoord memory centerPosition = getCAEntityPositionStrict(IStore(_world()), centerEntityId);

    // case one: center is the entity we care about, check neighbours to see if things need to change
    (bytes32 changedCenterEntityId, bytes memory centerEntityData) = runCaseOne(
      callerAddress,
      centerEntityId,
      centerPosition,
      neighbourEntityIds,
      childEntityIds,
      parentEntity
    );

    // case two: neighbour is the entity we care about, check center to see if things need to change
    (bytes32[] memory changedEntityIds, bytes[] memory neighbourEntitiesData) = runCaseTwo(
      callerAddress,
      centerEntityId,
      centerPosition,
      neighbourEntityIds,
      childEntityIds,
      parentEntity
    );

    bytes[] memory entityData = new bytes[](neighbourEntityIds.length + 1);
    entityData[0] = centerEntityData;
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      entityData[i + 1] = neighbourEntitiesData[i];
    }

    return (changedCenterEntityId, changedEntityIds, entityData);
  }
}
