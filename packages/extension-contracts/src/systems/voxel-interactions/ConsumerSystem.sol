// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SingleVoxelInteraction } from "@tenet-contracts/src/prototypes/SingleVoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Consumer, ConsumerData, PowerWire, PowerWireData, Storage, StorageData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { registerExtension, entityIsPowerWire, entityIsConsumer } from "../../Utils.sol";
import { getOppositeDirection } from "@tenet-contracts/src/Utils.sol";
import { BlockHeightUpdate } from "@tenet-contracts/src/Types.sol";

contract ConsumerSystem is SingleVoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    registerExtension(world, "ConsumerSystem", IWorld(world).extension_ConsumerSystem_eventHandler.selector);
  }

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view override returns (bool) {
    return entityIsConsumer(entityId, callerNamespace);
  }

  function usePowerWireAsSource(
    bytes16 callerNamespace,
    bytes32 powerWireEntity,
    BlockDirection powerWireDirection,
    bytes32 consumerEntity,
    ConsumerData memory consumerData
  ) internal returns (bool changedEntity) {
    PowerWireData memory sourceWireData = PowerWire.get(callerNamespace, powerWireEntity);
    if (sourceWireData.source == bytes32(0)) {
      return false;
    }

    bool consumerHasSource = consumerData.source != bytes32(0);
    if (consumerHasSource) {
      require(
        powerWireEntity == consumerData.source && powerWireDirection == consumerData.sourceDirection,
        "ConsumerSystem: source entity mismatch"
      );
    } else {
      consumerData.source = powerWireEntity;
      consumerData.sourceDirection = powerWireDirection;
    }

    if (
      !consumerHasSource ||
      consumerData.inRate != sourceWireData.transferRate ||
      consumerData.lastUpdateBlock != block.number
    ) {
      consumerData.inRate = sourceWireData.transferRate;
      consumerData.lastUpdateBlock = block.number;
      Consumer.set(callerNamespace, consumerEntity, consumerData);
      changedEntity = true;
    }
  }

  function runSingleInteraction(
    bytes16 callerNamespace,
    bytes32 consumerEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    ConsumerData memory consumerData = Consumer.get(callerNamespace, consumerEntity);
    changedEntity = false;

    bool isPowerWire = entityIsPowerWire(compareEntity, callerNamespace);

    bool doesHaveSource = consumerData.source != bytes32(0);

    if (!doesHaveSource) {
      if (isPowerWire) {
        changedEntity = usePowerWireAsSource(
          callerNamespace,
          compareEntity,
          compareBlockDirection,
          consumerEntity,
          consumerData
        );
      }
    } else if (compareBlockDirection == consumerData.sourceDirection) {
      if (
        entityIsPowerWire(consumerData.source, callerNamespace) &&
        PowerWire.get(callerNamespace, consumerData.source).source != bytes32(0)
      ) {
        changedEntity = usePowerWireAsSource(
          callerNamespace,
          compareEntity,
          compareBlockDirection,
          consumerEntity,
          consumerData
        );
      } else {
        consumerData.source = bytes32(0);
        consumerData.sourceDirection = BlockDirection.None;
        consumerData.inRate = 0;
        consumerData.lastUpdateBlock = block.number;
        ConsumerData.set(callerNamespace, consumerEntity, consumerData);
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
