// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { MindSystem as MindProtoSystem } from "@tenet-base-world/src/systems/MindSystem.sol";

contract MindSystem is MindProtoSystem {
  function setMindSelector(bytes32 objectEntityId, address mindAddress, bytes4 mindSelector) public override {
    super.setMindSelector(objectEntityId, mindAddress, mindSelector);
  }
}
