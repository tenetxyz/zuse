// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelCoord, EntityActionData, SimTable, Action } from "@tenet-utils/src/Types.sol";

import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";

import { getEntityAtCoord, getVoxelCoordStrict } from "@tenet-base-world/src/Utils.sol";
import { distanceBetween } from "@tenet-utils/src/VoxelCoordUtils.sol";
import { runSimAction } from "@tenet-base-simulator/src/CallUtils.sol";

abstract contract ActionSystem is System {
  function getSimulatorAddress() internal pure virtual returns (address);

  function preRunAction(bytes32 objectEntityId, VoxelCoord memory entityCoord, Action memory action) internal virtual {
    require(
      distanceBetween(entityCoord, action.targetCoord) <= 1,
      "Target can only be a surrounding neighbour or yourself"
    );
  }

  function runAction(bytes32 objectEntityId, VoxelCoord memory entityCoord, Action memory action) internal virtual {
    runSimAction(
      getSimulatorAddress(),
      objectEntityId,
      entityCoord,
      action.senderTable,
      action.senderValue,
      action.targetObjectEntityId,
      action.targetCoord,
      action.targetTable,
      action.targetValue
    );
  }

  function postRunAction(bytes32 objectEntityId, VoxelCoord memory entityCoord, Action memory action) internal virtual;

  function actionHandler(EntityActionData memory entityActionData) public virtual returns (bool ranAction) {
    if (entityActionData.actions.length == 0) {
      return false;
    }

    for (uint256 i = 0; i < entityActionData.actions.length; i++) {
      Action memory action = entityActionData.actions[i];
      VoxelCoord memory entityCoord = getVoxelCoordStrict(IStore(_world()), entityActionData.entityId);
      bytes32 objectEntityId = ObjectEntity.get(entityActionData.entityId);
      bytes32 targetObjectEntityId = ObjectEntity.get(getEntityAtCoord(IStore(_world()), action.targetCoord));
      require(uint256(targetObjectEntityId) != 0, "ActionSystem: targetObjectEntityId not found");
      if (uint256(action.targetObjectEntityId) == 0) {
        action.targetObjectEntityId = targetObjectEntityId;
      }
      require(action.targetObjectEntityId == targetObjectEntityId, "ActionSystem: targetObjectEntityId mismatch");

      preRunAction(objectEntityId, entityCoord, action);

      runAction(objectEntityId, entityCoord, action);

      postRunAction(objectEntityId, entityCoord, action);
    }

    return true;
  }
}
