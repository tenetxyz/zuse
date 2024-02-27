// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { ObjectMetadata, ObjectMetadataTableId } from "@tenet-world/src/codegen/tables/ObjectMetadata.sol";
import { KeysInTable } from "@latticexyz/world/src/modules/keysintable/tables/KeysInTable.sol";

import { SIMULATOR_ADDRESS, NUM_MAX_OBJECTS_INTERACTION_RUN, NUM_MAX_UNIQUE_OBJECT_EVENT_HANDLERS_RUN, NUM_MAX_SAME_OBJECT_EVENT_HANDLERS_RUN } from "@tenet-world/src/Constants.sol";
import { ObjectInteractionSystem as ObjectInteractionProtoSystem } from "@tenet-base-world/src/systems/ObjectInteractionSystem.sol";

contract ObjectInteractionSystem is ObjectInteractionProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function shouldRunEvent(bytes32 objectEntityId) internal override returns (bool) {
    uint256 numUniqueObjectsRan = KeysInTable.lengthKeys0(ObjectMetadataTableId);
    if (numUniqueObjectsRan + 1 > NUM_MAX_UNIQUE_OBJECT_EVENT_HANDLERS_RUN) {
      return false;
    }
    uint32 numSameObjectRan = ObjectMetadata.get(objectEntityId);
    if (numSameObjectRan > NUM_MAX_SAME_OBJECT_EVENT_HANDLERS_RUN) {
      return false;
    }
    ObjectMetadata.set(objectEntityId, numSameObjectRan + 1);

    return true;
  }

  function getNumMaxObjectsToRun() internal pure override returns (uint256) {
    return NUM_MAX_OBJECTS_INTERACTION_RUN;
  }

  function runInteractions(bytes32 centerEntityId) public override {
    return super.runInteractions(centerEntityId);
  }
}
