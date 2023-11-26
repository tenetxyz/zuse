// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { SimInitSystem as SimInitProtoSystem } from "@tenet-base-simulator/src/systems/SimInitSystem.sol";
import { ObjectProperties } from "@tenet-utils/src/Types.sol";

contract SimInitSystem is SimInitProtoSystem {
  function initObject(bytes32 objectEntityId, ObjectProperties memory initialProperties) public override {}
}
