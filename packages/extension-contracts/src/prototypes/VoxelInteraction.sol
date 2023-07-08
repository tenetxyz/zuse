// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { PositionData } from "@tenetxyz/contracts/src/codegen/tables/Position.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { BlockDirection } from "../codegen/Types.sol";
import { calculateBlockDirection, getEntityPositionStrict } from "../Utils.sol";

// TODO: This should be in @tenetxyz/contracts but it won't work because of some import issue
abstract contract VoxelInteraction is System {
  function registerInteraction() public virtual;

  function runInteraction(
    bytes16 callerNamespace,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections
  ) internal virtual returns (bool changedEntity);

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view virtual returns (bool);

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public virtual returns (bytes32, bytes32[] memory) {
    bytes32 changedCenterEntityId = 0;
    bytes32[] memory changedEntityIds = new bytes32[](neighbourEntityIds.length);
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    // TODO: require not root namespace

    PositionData memory centerPosition = getEntityPositionStrict(centerEntityId);

    // case one: center is the entity we care about, check neighbours to see if things need to change
    if (entityShouldInteract(centerEntityId, callerNamespace)) {
      BlockDirection[] memory neighbourEntityDirections = new BlockDirection[](neighbourEntityIds.length);
      for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
        bytes32 neighbourEntityId = neighbourEntityIds[i];
        if (uint256(neighbourEntityId) == 0) {
          neighbourEntityDirections[i] = BlockDirection.None;
          continue;
        }

        BlockDirection centerBlockDirection = calculateBlockDirection(
          getEntityPositionStrict(neighbourEntityId),
          centerPosition
        );
        neighbourEntityDirections[i] = centerBlockDirection;
      }
      bool changedEntity = runInteraction(
        callerNamespace,
        centerEntityId,
        neighbourEntityIds,
        neighbourEntityDirections
      );
      if (changedEntity) {
        changedCenterEntityId = centerEntityId;
      }
    }

    // case two: neighbour is the entity we care about, check center to see if things need to change
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];

      if (uint256(neighbourEntityId) == 0 || !entityShouldInteract(neighbourEntityId, callerNamespace)) {
        changedEntityIds[i] = 0;
        continue;
      }

      PositionData memory neighbourPosition = getEntityPositionStrict(neighbourEntityId);

      bytes32[] memory modNeighbourEntityIds = new bytes32[](neighbourEntityIds.length);
      BlockDirection[] memory modNeighbourEntityDirections = new BlockDirection[](neighbourEntityIds.length);
      for (uint8 j = 0; j < neighbourEntityIds.length; j++) {
        bytes32 modNeighbourEntityId = neighbourEntityIds[j];
        if (modNeighbourEntityId != neighbourEntityId) {
          modNeighbourEntityIds[j] = modNeighbourEntityId;
          if (uint256(modNeighbourEntityId) != 0) {
            BlockDirection modNeighbourBlockDirection = calculateBlockDirection(
              getEntityPositionStrict(modNeighbourEntityId),
              neighbourPosition
            );
            modNeighbourEntityDirections[j] = modNeighbourBlockDirection;
          } else {
            modNeighbourEntityDirections[j] = BlockDirection.None;
          }
        }
      }
      modNeighbourEntityIds[i] = centerEntityId;
      BlockDirection centerBlockDirection = calculateBlockDirection(centerPosition, neighbourPosition);
      modNeighbourEntityDirections[i] = centerBlockDirection;

      bool changedEntity = runInteraction(
        callerNamespace,
        neighbourEntityId,
        modNeighbourEntityIds,
        modNeighbourEntityDirections
      );

      if (changedEntity) {
        changedEntityIds[i] = neighbourEntityId;
      } else {
        changedEntityIds[i] = 0;
      }
    }

    return (changedCenterEntityId, changedEntityIds);
  }
}
