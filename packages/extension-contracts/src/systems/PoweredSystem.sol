// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Powered } from "../codegen/Tables.sol";

contract PoweredSystem is System {

  function eventHandler(bytes32 centerEntityId, bytes32[] memory neighbourEntityIds) public returns (bytes32[] memory changedEntityIds) {
    bytes32[] memory changedEntityIds = new bytes32[](neighbourEntityIds.length);

    // uint32 counter = Counter.get();
    // uint32 newValue = counter + 1;
    // Counter.set(newValue);

    return changedEntityIds;
  }

}