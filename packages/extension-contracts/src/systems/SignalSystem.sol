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

  function updateSignal(bytes32 signalEntity, bytes32 compareEntity, BlockDirection compareBlockDirection) private {
    bytes16 callerNamespace = getCallerNamespace();
    SignalData memory signalData = Signal.get(callerNamespace, signalEntity);

    bytes32[] memory compareKeyTuple = new bytes32[](2);
    compareKeyTuple[0] = bytes32((callerNamespace));
    compareKeyTuple[1] = bytes32((compareEntity));

    if(signalData.isActive){

    } else {
      // if we're not active, and the compare entity is active, we should become active
      // compare entity could be a signal source, or it could be an active signal
      bool isSignalSource = hasKey(SignalSourceTableId, compareKeyTuple);
      bool isActiveSignal = hasKey(SignalTableId, compareKeyTuple) && Signal.get(callerNamespace, compareEntity).isActive;
      if(isSignalSource || isActiveSignal){
        signalData.isActive = true;
        signalData.direction = compareBlockDirection;
        Signal.set(callerNamespace, signalEntity, signalData);
      }
    }
  }

  function eventHandler(bytes32 centerEntityId, bytes32[] memory neighbourEntityIds) public returns (bytes32[] memory changedEntityIds) {
    bytes32[] memory changedEntityIds = new bytes32[](neighbourEntityIds.length);
    bytes16 callerNamespace = getCallerNamespace();
    // TODO: require not root namespace

    bytes32[] memory keyTuple = new bytes32[](2);
    keyTuple[0] = bytes32((callerNamespace));
    keyTuple[1] = bytes32((centerEntityId));

    // case one: center is signal, check neighbours to see if things need to change
    // case two: neighbour is signal, check center to see if things need to change



    return changedEntityIds;
  }

}