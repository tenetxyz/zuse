// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { Metadata, MetadataTableId } from "@tenet-world/src/codegen/tables/Metadata.sol";
import { KeysInTable } from "@latticexyz/world/src/modules/keysintable/tables/KeysInTable.sol";

import { REGISTRY_ADDRESS, SIMULATOR_ADDRESS, NUM_MAX_OBJECTS_INTERACTION_RUN, NUM_MAX_UNIQUE_OBJECT_EVENT_HANDLERS_RUN, NUM_MAX_SAME_OBJECT_EVENT_HANDLERS_RUN } from "@tenet-world/src/Constants.sol";
import { ObjectInteractionSystem as ObjectInteractionProtoSystem } from "@tenet-base-world/src/systems/ObjectInteractionSystem.sol";

contract ObjectInteractionSystem is ObjectInteractionProtoSystem {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function shouldRunEvent(bytes32 objectEntityId) internal override returns (bool) {
    uint256 numUniqueObjectsRan = KeysInTable.lengthKeys0(MetadataTableId);
    if (numUniqueObjectsRan + 1 > NUM_MAX_UNIQUE_OBJECT_EVENT_HANDLERS_RUN) {
      return false;
    }
    if (Metadata.get(objectEntityId) > NUM_MAX_SAME_OBJECT_EVENT_HANDLERS_RUN) {
      return false;
    }
    Metadata.set(objectEntityId, Metadata.get(objectEntityId) + 1);

    return true;
  }

  function getNumMaxObjectsToRun() internal pure override returns (uint256) {
    return NUM_MAX_OBJECTS_INTERACTION_RUN;
  }

  function runInteractions(bytes32 centerEntityId) public override {
    return super.runInteractions(centerEntityId);
  }
}
