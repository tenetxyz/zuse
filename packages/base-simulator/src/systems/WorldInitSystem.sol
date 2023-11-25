// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { Properties } from "@tenet-utils/src/Types.sol";

abstract contract InitSystem is System {
  function initObject(bytes32 objectEntityId, Properties memory initialProperties) public virtual;
}
