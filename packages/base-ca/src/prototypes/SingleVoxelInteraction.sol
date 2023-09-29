// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelInteraction } from "@tenet-base-ca/src/prototypes/VoxelInteraction.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { BlockDirection, VoxelCoord } from "@tenet-utils/src/Types.sol";

abstract contract SingleVoxelInteraction is VoxelInteraction {
  function onNewNeighbour(
    address callerAddress,
    bytes32 neighbourEntityId,
    bytes32 centerEntityId,
    BlockDirection centerBlockDirection
  ) internal virtual override returns (bool changedEntity, bytes memory entityData) {
    return runSingleInteraction(callerAddress, neighbourEntityId, centerEntityId, centerBlockDirection);
  }

  function runSingleInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourEntityDirection
  ) internal virtual returns (bool changedEntity, bytes memory entityData);

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal virtual override returns (bool changedEntity, bytes memory entityData) {
    require(
      neighbourEntityIds.length == neighbourEntityDirections.length,
      "neighbourEntityIds and neighbourEntityDirections must be the same length"
    );
    changedEntity = false;
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];
      if (uint256(neighbourEntityId) == 0) {
        continue;
      }
      (bool changedInteractionEntity, bytes memory interactionEntityData) = runSingleInteraction(
        callerAddress,
        interactEntity,
        neighbourEntityId,
        neighbourEntityDirections[i]
      );
      if (entityData.length == 0 && interactionEntityData.length > 0) {
        entityData = interactionEntityData;
      }
      if (changedInteractionEntity) {
        changedEntity = true;
      }
    }
    return (changedEntity, entityData);
  }
}
