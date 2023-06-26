// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Signal, InvertedSignal, SignalData, InvertedSignalData, SignalTableId, InvertedSignalTableId, SignalSource, SignalSourceTableId } from "../codegen/Tables.sol";

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { BlockDirection } from "../codegen/Types.sol";
import { PositionData } from "@tenetxyz/contracts/src/codegen/tables/Position.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { calculateBlockDirection, getOppositeDirection, getEntityPositionStrict, entityIsSignal, entityIsInvertedSignal, entityIsPowered, entityIsSignalSource } from "../Utils.sol";

contract InvertedSignalSystem is System {
  function getOrCreateInvertedSignal(bytes32 entity) public returns (InvertedSignalData memory) {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());

    if (!entityIsInvertedSignal(entity, callerNamespace)) {
      InvertedSignal.set(
        callerNamespace,
        entity,
        InvertedSignalData({ isActive: true, direction: BlockDirection.None })
      );
    }

    return InvertedSignal.get(callerNamespace, entity);
  }

  function updateInvertedSignal(
    bytes16 callerNamespace,
    bytes32 invertedSignalEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) private returns (bool changedEntity) {
    InvertedSignalData memory invertedSignalData = InvertedSignal.get(callerNamespace, invertedSignalEntity);
    changedEntity = false;

    bool compareIsPowered = entityIsPowered(compareEntity, callerNamespace);
    PoweredData memory comparePoweredData;
    if (compareIsPowered) {
      comparePoweredData = Powered.get(callerNamespace, compareEntity);
    }
    bool compareIsSignalSource = entityIsSignalSource(compareEntity, callerNamespace);

    if (invertedSignalData.isActive) {
      // check if we should remain active
      // if compare is active powered and we're not the ones powering it
      // then we are now adjacent to a powered block, so we should become inactive
      if (
        compareIsPowered &&
        compareIsPowered.isActive &&
        compareIsPowered.direction != getOppositeDirection(compareBlockDirection)
      ) {
        invertedSignalData.isActive = false;
        invertedSignalData.direction = compareBlockDirection; // blocked direction
        InvertedSignal.set(callerNamespace, invertedSignalEntity, invertedSignalData);
        changedEntity = true;
      }
    } else {
      // check to see if we should be active?
      // were we previously blocked by an active powered block
      if (
        invertedSignalData.direction == compareBlockDirection &&
        (!compareIsPowered || (compareIsPowered && !compareIsPowered.isActive))
      ) {
        invertedSignalData.isActive = true;
        invertedSignalData.direction = BlockDirection.None;
        InvertedSignal.set(callerNamespace, invertedSignalEntity, invertedSignalData);
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

    PositionData memory centerPosition = getEntityPositionStrict(centerEntityId);

    // case one: center is signal, check neighbours to see if things need to change
    if (entityIsInvertedSignal(centerEntityId, callerNamespace)) {
      for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
        bytes32 neighbourEntityId = neighbourEntityIds[i];
        if (uint256(neighbourEntityId) == 0) {
          continue;
        }

        BlockDirection centerBlockDirection = calculateBlockDirection(
          getEntityPositionStrict(neighbourEntityId),
          centerPosition
        );
        updateInvertedSignal(callerNamespace, centerEntityId, neighbourEntityId, centerBlockDirection);
      }
    }

    // case two: neighbour is signal, check center to see if things need to change
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];

      if (uint256(neighbourEntityId) == 0 || !entityIsInvertedSignal(neighbourEntityId, callerNamespace)) {
        changedEntityIds[i] = 0;
        continue;
      }

      BlockDirection centerBlockDirection = calculateBlockDirection(
        centerPosition,
        getEntityPositionStrict(neighbourEntityId)
      );

      bool changedEntity = updateInvertedSignal(
        callerNamespace,
        neighbourEntityId,
        centerEntityId,
        centerBlockDirection
      );

      if (changedEntity) {
        changedEntityIds[i] = neighbourEntityId;
      } else {
        changedEntityIds[i] = 0;
      }
    }

    return changedEntityIds;
  }
}
