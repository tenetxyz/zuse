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

  function eventHandler(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) internal returns (bytes32, bytes memory) {
    VoxelCoord memory centerPosition = getCAEntityPositionStrict(IStore(_world()), centerEntityId);
    bytes32 changedCenterEntityId = 0;
    bytes memory centerEntityData;

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

    return (changedCenterEntityId, centerEntityData);
  }

  function neighbourEventHandler(
    address callerAddress,
    bytes32 interactEntity,
    bytes32 neighbourEntityId
  ) internal returns (bytes32, bytes memory) {
    bytes32 changedNeighbourEntityId = 0;
    bytes memory neighbourEntityData;

    BlockDirection centerBlockDirection = calculateBlockDirection(
      getCAEntityPositionStrict(IStore(_world()), neighbourEntityId), // center
      getCAEntityPositionStrict(IStore(_world()), interactEntity) // neighbour
    );

    (bool changedEntity, bytes memory entityData) = onNewNeighbour(callerAddress, interactEntity, neighbourEntityId, centerBlockDirection);
    neighbourEntityData = entityData;
    if(changedEntity){
      changedNeighbourEntityId = interactEntity;
    }

    return (changedNeighbourEntityId, neighbourEntityData);
  }

}
