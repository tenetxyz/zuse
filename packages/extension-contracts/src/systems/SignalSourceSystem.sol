// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Signal, SignalData, SignalTableId, SignalSource, SignalSourceTableId, InvertedSignal, InvertedSignalData } from "../codegen/Tables.sol";

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector } from "@latticexyz/world/src/ResourceSelector.sol";
import { BlockDirection } from "../codegen/Types.sol";
import { PositionData } from "@tenetxyz/contracts/src/codegen/tables/Position.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { calculateBlockDirection, getOppositeDirection, getEntityPositionStrict, entityIsSignal, entityIsSignalSource, entityIsInvertedSignal } from "../Utils.sol";

contract SignalSourceSystem is System {
  function getOrCreateSignalSource(bytes32 entity) public returns (bool) {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());

    if (!entityIsSignalSource(entity, callerNamespace)) {
      bool isNatural = true;
      SignalSource.set(callerNamespace, entity, isNatural);
    }

    return SignalSource.get(callerNamespace, entity);
  }

  function updateSignalSource(
    bytes16 callerNamespace,
    bytes32 signalSourceEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) private returns (bool changedEntity) {
    changedEntity = false;

    bool isSignalSource = entityIsSignalSource(signalSourceEntity, callerNamespace);
    bool isSignal = entityIsSignal(compareEntity, callerNamespace);
    bool isInvertedSignal = entityIsInvertedSignal(compareEntity, callerNamespace);
    if (isSignal || isInvertedSignal) return changedEntity; // these two cannot be a signal source
    bool isNaturalSignalSource = SignalSource.get(callerNamespace, signalSourceEntity);

    bool compareIsActiveInvertedSignal = entityIsInvertedSignal(compareEntity, callerNamespace);
    if (compareIsActiveInvertedSignal) {
      InvertedSignalData memory compareInvertedSignalData = InvertedSignal.get(callerNamespace, compareEntity);
      compareIsActiveInvertedSignal =
        compareInvertedSignalData.isActive &&
        compareInvertedSignalData.direction == BlockDirection.Down;
    }

    if (isSignalSource) {
      // Check if the signal source is still valid
      if (!isNaturalSignalSource && compareBlockDirection == BlockDirection.Down && !compareIsActiveInvertedSignal) {
        SignalSource.deleteRecord(callerNamespace, signalSourceEntity);
        changedEntity = true;
      }
    } else {
      // if a voxel is not a signal source and above a inverted active signal
      // then it should be a signal source
      if (compareIsActiveInvertedSignal) {
        bool isNatural = false;
        SignalSource.set(callerNamespace, signalSourceEntity, isNatural);
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
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];
      if (uint256(neighbourEntityId) == 0) {
        continue;
      }

      BlockDirection centerBlockDirection = calculateBlockDirection(
        getEntityPositionStrict(neighbourEntityId),
        centerPosition
      );
      updateSignalSource(callerNamespace, centerEntityId, neighbourEntityId, centerBlockDirection);
    }

    // case two: neighbour is signal, check center to see if things need to change
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 neighbourEntityId = neighbourEntityIds[i];

      if (uint256(neighbourEntityId) == 0) {
        changedEntityIds[i] = 0;
        continue;
      }

      BlockDirection centerBlockDirection = calculateBlockDirection(
        centerPosition,
        getEntityPositionStrict(neighbourEntityId)
      );

      bool changedEntity = updateSignalSource(callerNamespace, neighbourEntityId, centerEntityId, centerBlockDirection);

      if (changedEntity) {
        changedEntityIds[i] = neighbourEntityId;
      } else {
        changedEntityIds[i] = 0;
      }
    }

    return changedEntityIds;
  }
}
