// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelInteraction } from "./VoxelInteraction.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { BlockDirection, VoxelCoord } from "@tenet-utils/src/Types.sol";

abstract contract SingleVoxelInteraction is VoxelInteraction {
  function onNewNeighbour(
    bytes16 callerNamespace,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourBlockDirection
  ) internal override returns (bool changedEntity) {
    changedEntity = runSingleInteraction(callerNamespace, interactEntity, neighbourEntityId, neighbourBlockDirection);
    return changedEntity;
  }

  function runSingleInteraction(
    bytes16 callerNamespace,
    bytes32 interactEntity,
    bytes32 neighbourEntityId,
    BlockDirection neighbourEntityDirection
  ) internal virtual returns (bool changedEntity);

  function runInteraction(
    address callerAddress,
    bytes32 interactEntity,
    bytes32[] memory neighbourEntityIds,
    BlockDirection[] memory neighbourEntityDirections,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal override returns (bool changedEntity) {
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
      bool changedInteractionEntity = runSingleInteraction(
        callerNamespace,
        interactEntity,
        neighbourEntityId,
        neighbourEntityDirections[i]
      );
      if (changedInteractionEntity) {
        changedEntity = true;
      }
    }
    return changedEntity;
  }
}
