// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca-extensions-1/src/codegen/world/IWorld.sol";
import { SingleVoxelInteraction } from "@tenet-base-ca/src/prototypes/SingleVoxelInteraction.sol";
import { Consumer, ConsumerData, PowerWire, PowerWireData, Storage, StorageData } from "@tenet-level2-ca-extensions-1/src/codegen/Tables.sol";
import { BlockDirection, BlockHeightUpdate } from "@tenet-utils/src/Types.sol";
import { entityIsPowerWire, entityIsConsumer } from "@tenet-level2-ca-extensions-1/src/InteractionUtils.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";

contract ConsumerSystem is SingleVoxelInteraction {
  function usePowerWireAsSource(
    address callerAddress,
    bytes32 powerWireEntity,
    BlockDirection powerWireDirection,
    bytes32 consumerEntity,
    ConsumerData memory consumerData
  ) internal returns (bool changedEntity) {
    PowerWireData memory sourceWireData = PowerWire.get(callerAddress, powerWireEntity);
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
      Consumer.set(callerAddress, consumerEntity, consumerData);
      changedEntity = true;
    }
  }

  function runSingleInteraction(
    address callerAddress,
    bytes32 consumerEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity, bytes memory entityData) {
    ConsumerData memory consumerData = Consumer.get(callerAddress, consumerEntity);
    changedEntity = false;

    if (
      compareBlockDirection == BlockDirection.NorthEast ||
      compareBlockDirection == BlockDirection.NorthWest ||
      compareBlockDirection == BlockDirection.SouthEast ||
      compareBlockDirection == BlockDirection.SouthWest
    ) {
      return (false, entityData);
    }

    bool isPowerWire = entityIsPowerWire(callerAddress, compareEntity);

    bool doesHaveSource = consumerData.source != bytes32(0);

    if (!doesHaveSource) {
      if (isPowerWire) {
        changedEntity = usePowerWireAsSource(
          callerAddress,
          compareEntity,
          compareBlockDirection,
          consumerEntity,
          consumerData
        );
      }
    } else if (compareBlockDirection == consumerData.sourceDirection) {
      if (
        entityIsPowerWire(callerAddress, consumerData.source) &&
        PowerWire.get(callerAddress, consumerData.source).source != bytes32(0)
      ) {
        changedEntity = usePowerWireAsSource(
          callerAddress,
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
        Consumer.set(callerAddress, consumerEntity, consumerData);
        changedEntity = true;
      }
    }

    return (changedEntity, entityData);
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    return entityIsConsumer(callerAddress, entityId);
  }

  function eventHandlerConsumer(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory, bytes[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
