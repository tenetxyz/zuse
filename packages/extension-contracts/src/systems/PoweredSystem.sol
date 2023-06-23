// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Powered, PoweredData, PoweredTableId } from "../codegen/Tables.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector} from "@latticexyz/world/src/ResourceSelector.sol";

contract PoweredSystem is System {

  // TODO: Implement
  function createNew(bytes32 entity) public {

  }

  function eventHandler(bytes32 centerEntityId, bytes32[] memory neighbourEntityIds) public returns (bytes32[] memory changedEntityIds) {
    bytes32[] memory changedEntityIds = new bytes32[](neighbourEntityIds.length);

    return changedEntityIds;
  }

}