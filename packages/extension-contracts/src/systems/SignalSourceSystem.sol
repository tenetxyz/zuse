// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { SignalSource, SignalSourceTableId } from "../codegen/Tables.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

import { getCallerNamespace } from "../Utils.sol";

contract SignalSourceSystem is System {

  function createNew(bytes32 entity) public {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());

    bytes32[] memory keyTuple = new bytes32[](2);
    keyTuple[0] = bytes32((callerNamespace));
    keyTuple[1] = bytes32((entity));

    require(!hasKey(SignalSourceTableId, keyTuple), "Entity already exists");

    bool isNatural = true;

    SignalSource.set(callerNamespace, entity, isNatural);
  }

  function eventHandler(bytes32 centerEntityId, bytes32[] memory neighbourEntityIds) public returns (bytes32[] memory changedEntityIds) {
    bytes32[] memory changedEntityIds = new bytes32[](neighbourEntityIds.length);

    return changedEntityIds;
  }

}