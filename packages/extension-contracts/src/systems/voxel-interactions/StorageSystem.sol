// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SingleVoxelInteraction } from "@tenet-contracts/src/prototypes/SingleVoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { PowerWire, PowerWireData, Storage, StorageData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { registerExtension, entityIsStorage } from "../../Utils.sol";
import { getOppositeDirection } from "@tenet-contracts/src/Utils.sol";

contract StorageSystem is SingleVoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    registerExtension(world, "StorageSystem", IWorld(world).extension_StorageSystem_eventHandler.selector);
  }

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view override returns (bool) {
    return entityIsStorage(entityId, callerNamespace);
  }

  function runSingleInteraction(
    bytes16 callerNamespace,
    bytes32 signalEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {



    }
    return changedEntity;
  }

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public override returns (bytes32, bytes32[] memory) {
    return super.eventHandler(centerEntityId, neighbourEntityIds);
  }
}
