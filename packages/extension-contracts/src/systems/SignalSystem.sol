// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Signal, SignalData, SignalTableId, SignalSource, SignalSourceTableId } from "../codegen/Tables.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector} from "@latticexyz/world/src/ResourceSelector.sol";
import {BlockDirection} from "../codegen/Types.sol";

contract SignalSystem is System {

  function getCallerNamespace() private returns (bytes16) {
    address caller = _msgSender();
    require(uint256(SystemRegistry.get(caller)) != 0, "Caller is not a system"); // cannot be called by an EOA
    bytes32 resourceSelector = SystemRegistry.get(caller);
    bytes16 callerNamespace = ResourceSelector.getNamespace(resourceSelector);
    return callerNamespace;
  }

  function createNew(bytes32 entity) public {
    bytes16 callerNamespace = getCallerNamespace();

    bytes32[] memory keyTuple = new bytes32[](2);
    keyTuple[0] = bytes32((callerNamespace));
    keyTuple[1] = bytes32((entity));

    require(!hasKey(SignalTableId, keyTuple), "Entity already exists");

    Signal.set(callerNamespace, entity, SignalData({
      isActive: false,
      direction: BlockDirection.None
    }));
  }

  function updateSignal(bytes32 signalEntity, bytes32 compareEntity, BlockDirection compareBlockDirection) private returns (bool) {
    bytes16 callerNamespace = getCallerNamespace();
    SignalData memory signalData = Signal.get(callerNamespace, signalEntity);
    bool changedSignalEntity = false;

    bytes32[] memory compareKeyTuple = new bytes32[](2);
    compareKeyTuple[0] = bytes32((callerNamespace));
    compareKeyTuple[1] = bytes32((compareEntity));

    bool compareIsSignalSource = hasKey(SignalSourceTableId, compareKeyTuple);
    bool compareIsActiveSignal = hasKey(SignalTableId, compareKeyTuple) && Signal.get(callerNamespace, compareEntity).isActive;

    if(signalData.isActive){
      // if we're active and the source direction is the same as the compare block direction
      // and if the compare entity is not active, we should become inactive
      if(signalData.direction == compareBlockDirection){
        if(!compareIsSignalSource && !compareIsActiveSignal){
          signalData.isActive = false;
          signalData.direction = BlockDirection.None;
          Signal.set(callerNamespace, signalEntity, signalData);
          changedSignalEntity = true;
        }
      }
    } else {
      // if we're not active, and the compare entity is active, we should become active
      // compare entity could be a signal source, or it could be an active signal
      if(compareIsSignalSource || compareIsActiveSignal){
        signalData.isActive = true;
        signalData.direction = compareBlockDirection;
        Signal.set(callerNamespace, signalEntity, signalData);
        changedSignalEntity = true;
      }
    }

    return changedSignalEntity;
  }

  function eventHandler(bytes32 centerEntityId, bytes32[] memory neighbourEntityIds) public returns (bytes32[] memory) {
    bytes32[] memory changedEntityIds = new bytes32[](neighbourEntityIds.length);
    bytes16 callerNamespace = getCallerNamespace();
    // TODO: require not root namespace

    bytes32[] memory keyTuple = new bytes32[](2);
    keyTuple[0] = bytes32((callerNamespace));
    keyTuple[1] = bytes32((centerEntityId));

    // TODO: Need to read Position from caller namespace
    // require(positionComponent.has(centerEntityId), "centerEntityId must have a position"); // even if its air, it must have a position
    // VoxelCoord memory centerPosition = positionComponent.getValue(centerEntityId);

    // case one: center is signal, check neighbours to see if things need to change
    bool centerIsSignal = hasKey(SignalTableId, keyTuple);
    if(centerIsSignal){
        for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
          bytes32 neighbourEntityId = neighbourEntityIds[i];
          // BlockDirection centerBlockDirection = calculateBlockDirection(
          //   centerPosition,
          //   positionComponent.getValue(neighbourEntityId)
          // );
          updateSignal(centerEntityId, neighbourEntityId, BlockDirection.North);
        }
    }

    // case two: neighbour is signal, check center to see if things need to change
    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
        bytes32 neighbourEntityId = neighbourEntityIds[i];

        bytes32[] memory neighbourKeyTuple = new bytes32[](2);
        neighbourKeyTuple[0] = bytes32((callerNamespace));
        neighbourKeyTuple[1] = bytes32((neighbourEntityId));

        bool neighbourIsSignal = hasKey(SignalTableId, neighbourKeyTuple);

        if (neighbourEntityId == 0 || !neighbourIsSignal) {
          changedEntityIds[i] = 0;
          continue;
        }
        // BlockDirection centerBlockDirection = calculateBlockDirection(
        //   centerPosition,
        //   positionComponent.getValue(neighbourEntityId)
        // );

        bool changedEntity = updateSignal(neighbourEntityId, centerEntityId, BlockDirection.North);

        if(changedEntity){
          changedEntityIds[i] = neighbourEntityId;
        } else {
          changedEntityIds[i] = 0;
        }
    }

    return changedEntityIds;
  }

}