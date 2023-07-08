// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SingleVoxelInteraction } from "../../prototypes/SingleVoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Signal, SignalData, Powered, PoweredData, PoweredTableId, SignalSource, SignalSourceTableId } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { registerExtension, entityIsPowered, entityIsSignal, entityIsSignalSource } from "../../Utils.sol";

contract PoweredSystem is SingleVoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    registerExtension(world, "PoweredSystem", IWorld(world).extension_PoweredSystem_eventHandler.selector);
  }

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view override returns (bool) {
    return entityIsPowered(entityId, callerNamespace);
  }

  function runSingleInteraction(
    bytes16 callerNamespace,
    bytes32 poweredEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    PoweredData memory poweredData = Powered.get(callerNamespace, poweredEntity);
    changedEntity = false;

    bool compareIsSignalSource = entityIsSignalSource(compareEntity, callerNamespace);
    bool compareIsActiveSignal = entityIsSignal(compareEntity, callerNamespace);
    if (compareIsActiveSignal) {
      SignalData memory compareSignalData = Signal.get(callerNamespace, compareEntity);
      compareIsActiveSignal =
        compareSignalData.isActive &&
        (compareSignalData.direction == compareBlockDirection || compareBlockDirection == BlockDirection.Down);
    }

    if (poweredData.isActive) {
      // if we're active and the source direction is the same as the compare block direction
      // and if the compare entity is not active, we should become inactive
      if (poweredData.direction == compareBlockDirection) {
        if (!compareIsSignalSource && !compareIsActiveSignal) {
          poweredData.isActive = false;
          poweredData.direction = BlockDirection.None;
          Powered.set(callerNamespace, poweredEntity, poweredData);
          changedEntity = true;
        }
      }
    } else {
      // if we're not active, and the compare entity is active, we should become active
      // compare entity could be a signal source, or it could be an active signal that's in our direction or below us
      if (compareIsSignalSource || compareIsActiveSignal) {
        poweredData.isActive = true;
        poweredData.direction = compareBlockDirection;
        Powered.set(callerNamespace, poweredEntity, poweredData);
        changedEntity = true;
      }
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
