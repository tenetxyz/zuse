// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SingleVoxelInteraction } from "@tenet-contracts/src/prototypes/SingleVoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { PowerWire, PowerWireData, Storage, StorageData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { registerExtension, entityIsStorage, entityIsPowerWire } from "../../Utils.sol";
import { getOppositeDirection } from "@tenet-contracts/src/Utils.sol";

contract StorageSystem is SingleVoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    registerExtension(world, "StorageSystem", IWorld(world).extension_StorageSystem_eventHandler.selector);
  }

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view override returns (bool) {
    return entityIsStorage(entityId, callerNamespace);
  }

  function usePowerWireAsSource(
    bytes16 callerNamespace,
    bytes32 powerWireEntity,
    BlockDirection powerWireDirection,
    bytes32 storageEntity,
    StorageData memory storageData
  ) internal returns (bool changedEntity) {
    PowerWireData memory sourceWireData = PowerWire.get(callerNamespace, powerWireEntity);
    if (sourceWireData.source == bytes32(0)) {
      return false;
    }

    bool storageHasSource = storageData.source != bytes32(0);
    if (storageHasSource) {
      require(
        powerWireEntity == storageData.source && powerWireDirection == storageData.sourceDirection,
        "StorageSystem: source entity mismatch"
      );
    } else {
      storageData.source = powerWireEntity;
      storageData.sourceDirection = powerWireDirection;
    }

    if (!storageHasSource || storageData.lastUpdateBlock != block.number) {
      uint256 newEnergyToStore = ((sourceWireData.transferRate + storageData.lastInRate) / 2) *
        (block.number - storageData.lastUpdateBlock);
      uint256 proposedEnergyStored = newEnergyToStore + storageData.energyStored;

      storageData.energyStored = (proposedEnergyStored > storageData.maxStorage)
        ? storageData.maxStorage
        : proposedEnergyStored;
      storageData.lastInRate = sourceWireData.transferRate;
      storageData.lastUpdateBlock = block.number;
      Storage.set(callerNamespace, storageEntity, storageData);
      changedEntity = true;
    }
  }

  function usePowerWireAsDestination(
    bytes16 callerNamespace,
    bytes32 powerWireEntity,
    BlockDirection powerWireDirection,
    bytes32 storageEntity,
    StorageData memory storageData
  ) internal returns (bool changedEntity) {
    PowerWireData memory destinationWireData = PowerWire.get(callerNamespace, powerWireEntity);
    if (destinationWireData.source != bytes32(0) && destinationWireData.source != storageEntity) {
      revert("StorageSystem: Storage is trying to use a wire as a destination that already has a different source");
    }

    bool storageHasDestination = storageData.destination != bytes32(0);

    if (storageHasDestination) {
      require(
        powerWireEntity == storageData.destination && powerWireDirection == storageData.destinationDirection,
        "StorageSystem: Storage has a destination and is trying to connect to a different destination"
      );
    } else {
      storageData.destination = powerWireEntity;
      storageData.destinationDirection = powerWireDirection;
    }

    if (!storageHasDestination || storageData.lastUpdateBlock != block.number) {
      if (block.number != storageData.lastUpdateBlock) {
        uint256 validTransferRate = 2 *
          (storageData.energyStored / (block.number - storageData.lastUpdateBlock)) -
          storageData.lastOutRate;
        if (validTransferRate > destinationWireData.maxTransferRate) {
          validTransferRate = destinationWireData.maxTransferRate;
        }
        uint256 energyToLeave = ((storageData.lastOutRate + validTransferRate) / 2) *
          (block.number - storageData.lastUpdateBlock);

        storageData.energyStored = storageData.energyStored - energyToLeave;
        storageData.lastOutRate = validTransferRate;
        storageData.lastUpdateBlock = block.number;
      }

      Storage.set(callerNamespace, storageEntity, storageData);
      changedEntity = true;
    }
  }

  function runSingleInteraction(
    bytes16 callerNamespace,
    bytes32 storageEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    StorageData memory storageData = Storage.get(callerNamespace, storageEntity);
    changedEntity = false;

    bool isPowerWire = entityIsPowerWire(compareEntity, callerNamespace);

    bool doesHaveSource = storageData.source != bytes32(0);

    if (!doesHaveSource) {
      if (isPowerWire) {
        changedEntity = usePowerWireAsSource(
          callerNamespace,
          compareEntity,
          compareBlockDirection,
          storageEntity,
          storageData
        );
      }
    } else {
      if (compareBlockDirection == storageData.sourceDirection) {
        if (
          entityIsPowerWire(storageData.source, callerNamespace) &&
          PowerWire.get(callerNamespace, storageData.source).source != bytes32(0)
        ) {
          changedEntity = usePowerWireAsSource(
            callerNamespace,
            compareEntity,
            compareBlockDirection,
            storageEntity,
            storageData
          );
        } else {
          storageData.lastInRate = 0;
          storageData.lastUpdateBlock = block.number;
          storageData.source = bytes32(0);
          storageData.sourceDirection = BlockDirection.None;
          Storage.set(callerNamespace, storageEntity, storageData);
          changedEntity = true;
        }
      } else if (compareBlockDirection == storageData.destinationDirection) {
        if (entityIsPowerWire(storageData.destination, callerNamespace)) {
          changedEntity = usePowerWireAsDestination(
            callerNamespace,
            compareEntity,
            compareBlockDirection,
            storageEntity,
            storageData
          );
        } else {
          storageData.lastOutRate = 0;
          storageData.lastUpdateBlock = block.number;
          storageData.destination = bytes32(0);
          storageData.destinationDirection = BlockDirection.None;
          Storage.set(callerNamespace, storageEntity, storageData);
          changedEntity = true;
        }
      } else {
        if (isPowerWire) {
          changedEntity = usePowerWireAsDestination(
            callerNamespace,
            compareEntity,
            compareBlockDirection,
            storageEntity,
            storageData
          );
        }
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
