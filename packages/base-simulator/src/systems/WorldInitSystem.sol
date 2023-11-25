// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { ObjectProperties } from "@tenet-utils/src/Types.sol";

abstract contract WorldInitSystem is System {
  function initObject(bytes32 objectEntityId, ObjectProperties memory initialProperties) public virtual;
}
