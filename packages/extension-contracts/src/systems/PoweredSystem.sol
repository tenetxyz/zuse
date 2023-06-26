// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Signal, SignalData, Powered, PoweredData, PoweredTableId, SignalSource, SignalSourceTableId } from "../codegen/Tables.sol";

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { BlockDirection } from "../codegen/Types.sol";
import { PositionData } from "@tenetxyz/contracts/src/codegen/tables/Position.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { calculateBlockDirection, getOppositeDirection, getEntityPositionStrict, entityIsPowered, entityIsSignal, entityIsSignalSource } from "../Utils.sol";

contract PoweredSystem is System {
  function getOrCreatePowered(bytes32 entity) public returns (PoweredData memory) {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());

    if (!entityIsPowered(entity, callerNamespace)) {
      Powered.set(callerNamespace, entity, PoweredData({ isActive: false, direction: BlockDirection.None }));
    }

    return Powered.get(callerNamespace, entity);
  }

  function createPoweredIfNotExists(bytes32 entity, bytes16 callerNamespace) private {
    if (
      uint256(entity) != 0 &&
      !entityIsPowered(entity, callerNamespace) &&
      !entityIsSignal(entity, callerNamespace) &&
      !entityIsSignalSource(entity, callerNamespace)
    ) {
      Powered.set(callerNamespace, entity, PoweredData({ isActive: false, direction: BlockDirection.None }));
    }
  }

  function updatePowered(
    bytes16 callerNamespace,
    bytes32 poweredEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) private returns (bool changedEntity) {
    changedEntity = false;
    PoweredData memory poweredData = Powered.get(callerNamespace, poweredEntity);

    bool compareIsSignalSource = entityIsSignalSource(compareEntity, callerNamespace);
    bool compareIsActiveSignal = entityIsSignal(compareEntity, callerNamespace);
    if (compareIsActiveSignal) {
      SignalData memory compareSignalData = Signal.get(callerNamespace, compareEntity);
      compareIsActiveSignal =
        compareSignalData.isActive &&
        (compareSignalData.direction == compareBlockDirection || compareBlockDirection == BlockDirection.Down);
    }

    if (poweredData.isActive) {
      // if we're active and the source direction is the same as the compare block direction
      // and if the compare entity is not active, we should become inactive
      if (poweredData.direction == compareBlockDirection) {
        if (!compareIsSignalSource && !compareIsActiveSignal) {
          poweredData.isActive = false;
          poweredData.direction = BlockDirection.None;
          Powered.set(callerNamespace, poweredEntity, poweredData);
          changedEntity = true;
        }
      }
    } else {
      // if we're not active, and the compare entity is active, we should become active
      // compare entity could be a signal source, or it could be an active signal that's in our direction or below us
      if (compareIsSignalSource || compareIsActiveSignal) {
        poweredData.isActive = true;
        poweredData.direction = compareBlockDirection;
        Powered.set(callerNamespace, poweredEntity, poweredData);
        changedEntity = true;
      }
    }

    return changedEntity;
  }

  // TODO: The logic in this function will be the same for all eventHandlers, so we should somehow generalize this for all of them
  // through a library or something
  function eventHandler(bytes32 centerEntityId, bytes32[] memory neighbourEntityIds) public returns (bytes32[] memory) {
    bytes32[] memory changedEntityIds = new bytes32[](neighbourEntityIds.length);
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    // TODO: require not root namespace

    // all valid blocks should have powered data
    createPoweredIfNotExists(centerEntityId, callerNamespace);

    PositionData memory centerPosition = getEntityPositionStrict(centerEntityId);

    // case one: center is signal, check neighbours to see if things need to change
    if (entityIsPowered(centerEntityId, callerNamespace)) {
      for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
        bytes32 neighbourEntityId = neighbourEntityIds[i];
        if (uint256(neighbourEntityId) == 0) {
          continue;
        }

        BlockDirection centerBlockDirection = calculateBlockDirection(
          getEntityPositionStrict(neighbourEntityId),
          centerPosition
        );
        updatePowered(callerNamespace, centerEntityId, neighbourEntityId, centerBlockDirection);
      }
    }

    // case two: neighbour is signal, check center to see if things need to change
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];

      createPoweredIfNotExists(neighbourEntityId, callerNamespace);

      if (uint256(neighbourEntityId) == 0 || !entityIsPowered(neighbourEntityId, callerNamespace)) {
        changedEntityIds[i] = 0;
        continue;
      }

      BlockDirection centerBlockDirection = calculateBlockDirection(
        centerPosition,
        getEntityPositionStrict(neighbourEntityId)
      );

      bool changedEntity = updatePowered(callerNamespace, neighbourEntityId, centerEntityId, centerBlockDirection);

      if (changedEntity) {
        changedEntityIds[i] = neighbourEntityId;
      } else {
        changedEntityIds[i] = 0;
      }
    }

    return changedEntityIds;
  }
}
