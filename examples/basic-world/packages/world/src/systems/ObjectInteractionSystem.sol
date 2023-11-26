// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { REGISTRY_ADDRESS, NUM_MAX_OBJECTS_INTERACTION_RUN } from "@tenet-world/src/Constants.sol";
import { ObjectInteractionSystem as ObjectInteractionProtoSystem } from "@tenet-base-world/src/systems/ObjectInteractionSystem.sol";

contract ObjectInteractionSystem is ObjectInteractionProtoSystem {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function preRunInteraction(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) internal override {}

  function shouldRunEvent(bytes32 objectEntityId) internal view override returns (bool) {
    return true;
  }

  function getNumMaxObjectsToRun() internal pure override returns (uint256) {
    return NUM_MAX_OBJECTS_INTERACTION_RUN;
  }

  function runInteractions(bytes32 centerEntityId) public override {
    return super.runInteractions(centerEntityId);
  }
}
