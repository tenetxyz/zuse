// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelInteraction } from "@tenetxyz/contracts/src/prototypes/VoxelInteraction.sol";

import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Signal, InvertedSignal, SignalData, InvertedSignalData, SignalTableId, SignalSource, PoweredData, Powered } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { registerExtension, getOppositeDirection, entityIsSignal, entityIsInvertedSignal, entityIsPowered, entityIsSignalSource } from "../../Utils.sol";

contract InvertedSignalSystem is VoxelInteraction {
  function registerVoxelInteraction() public override {
    address world = _world();
    registerExtension(world, "InvertedSignalSystem", IWorld(world).extension_InvertedSignalSy_eventHandler.selector);
  }

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view override returns (bool) {
    return entityIsInvertedSignal(entityId, callerNamespace);
  }

  function runInteraction(
    bytes16 callerNamespace,
    bytes32 invertedSignalEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    InvertedSignalData memory invertedSignalData = InvertedSignal.get(callerNamespace, invertedSignalEntity);
    changedEntity = false;

    bool compareIsPowered = entityIsPowered(compareEntity, callerNamespace);
    PoweredData memory comparePoweredData;
    if (compareIsPowered) {
      comparePoweredData = Powered.get(callerNamespace, compareEntity);
    }
    bool compareIsSignalSource = entityIsSignalSource(compareEntity, callerNamespace);

    if (invertedSignalData.isActive) {
      // check if we should remain active
      // if compare is active powered and we're not the ones powering it
      // then we are now adjacent to a powered block, so we should become inactive
      if (
        compareIsPowered &&
        comparePoweredData.isActive &&
        comparePoweredData.direction != getOppositeDirection(compareBlockDirection)
      ) {
        invertedSignalData.isActive = false;
        invertedSignalData.direction = compareBlockDirection; // blocked direction
        InvertedSignal.set(callerNamespace, invertedSignalEntity, invertedSignalData);
        changedEntity = true;
      }
    } else {
      // check to see if we should be active?
      // were we previously blocked by an active powered block
      if (
        invertedSignalData.direction == compareBlockDirection &&
        (!compareIsPowered || (compareIsPowered && !comparePoweredData.isActive))
      ) {
        invertedSignalData.isActive = true;
        invertedSignalData.direction = BlockDirection.None;
        InvertedSignal.set(callerNamespace, invertedSignalEntity, invertedSignalData);
        changedEntity = true;
      }
    }

    return changedEntity;
  }

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds
  ) public override returns (bytes32[] memory) {
    return super.eventHandler(centerEntityId, neighbourEntityIds);
  }
}
