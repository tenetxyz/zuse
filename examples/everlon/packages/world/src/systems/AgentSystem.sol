// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { AgentSystem as AgentProtoSystem } from "@tenet-base-world/src/systems/AgentSystem.sol";

contract AgentSystem is AgentProtoSystem {
  function claimAgent(bytes32 agentEntityId) public override {
    return super.claimAgent(agentEntityId);
  }
}
