// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { SignalSource, SignalSourceTableId } from "../codegen/Tables.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { entityIsSignalSource } from "../utils.sol";

contract SignalSourceSystem is System {
  function getOrCreateSignalSource(bytes32 entity) public returns (bool) {
    bytes16 callerNamespace = getCallerNamespace(_msgSender());

    if (!entityIsSignalSource(entity, callerNamespace)) {
      bool isNatural = true;
      SignalSource.set(callerNamespace, entity, isNatural);
    }

    return SignalSource.get(callerNamespace, entity);
  }

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public returns (bytes32[] memory changedEntityIds) {
    bytes32[] memory changedEntityIds = new bytes32[](neighbourEntityIds.length);

    return changedEntityIds;
  }
}
