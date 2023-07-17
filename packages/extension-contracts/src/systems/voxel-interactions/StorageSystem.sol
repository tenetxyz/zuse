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
    if (sourceWireData.source == bytes32(0) || sourceWireData.source == storageEntity) {
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

    uint256 newEnergyStored = storageData.energyStored;
    if (block.number != storageData.lastInUpdateBlock) {
      uint256 newEnergyToStore = ((sourceWireData.transferRate + storageData.lastInRate) / 2) *
        (block.number - storageData.lastInUpdateBlock);
      uint256 proposedEnergyStored = newEnergyToStore + storageData.energyStored;
      newEnergyStored = (proposedEnergyStored > storageData.maxStorage) ? storageData.maxStorage : proposedEnergyStored;
    }

    if (!storageHasSource || storageData.lastInUpdateBlock != block.number) {
      storageData.energyStored = newEnergyStored;
      storageData.lastInRate = sourceWireData.transferRate;
      storageData.lastInUpdateBlock = block.number;
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
    if (storageData.source == powerWireEntity || destinationWireData.source == storageEntity) {
      // the source cant be the destination
      return false;
    }

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

    uint256 newEnergyStored = storageData.energyStored;
    uint256 validTransferRate = storageData.lastOutRate;
    if (block.number != storageData.lastOutUpdateBlock) {
      validTransferRate = 2 * (storageData.energyStored / (block.number - storageData.lastOutUpdateBlock));
      if (validTransferRate < storageData.lastOutRate) {
        validTransferRate = 0;
      } else {
        validTransferRate -= storageData.lastOutRate;
      }
      if (validTransferRate > destinationWireData.maxTransferRate) {
        validTransferRate = destinationWireData.maxTransferRate;
      }
      uint256 energyToLeave = ((storageData.lastOutRate + validTransferRate) / 2) *
        (block.number - storageData.lastOutUpdateBlock);
      newEnergyStored = storageData.energyStored;
      if (newEnergyStored < energyToLeave) {
        newEnergyStored = 0;
      } else {
        newEnergyStored -= energyToLeave;
      }
    }

    if (!storageHasDestination || storageData.lastOutUpdateBlock != block.number) {
      storageData.energyStored = newEnergyStored;
      storageData.lastOutRate = validTransferRate;
      storageData.lastOutUpdateBlock = block.number;
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

    bool isEnergyStored = storageData.energyStored > 0;

    bool doesHaveSource = storageData.source != bytes32(0);
    bool doesHaveDest = storageData.destination != bytes32(0);

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
    } else if (compareBlockDirection == storageData.sourceDirection) {
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
        storageData.lastInUpdateBlock = block.number;
        storageData.source = bytes32(0);
        storageData.sourceDirection = BlockDirection.None;
        Storage.set(callerNamespace, storageEntity, storageData);
        changedEntity = true;
      }
    }

    if ((isEnergyStored || doesHaveSource) && !doesHaveDest) {
      // only if you have energy add a destination
      if (isPowerWire) {
        changedEntity = usePowerWireAsDestination(
          callerNamespace,
          compareEntity,
          compareBlockDirection,
          storageEntity,
          storageData
        );
      }
    } else if (compareBlockDirection == storageData.destinationDirection) {
      if (entityIsPowerWire(storageData.destination, callerNamespace) && isEnergyStored) {
        changedEntity = usePowerWireAsDestination(
          callerNamespace,
          compareEntity,
          compareBlockDirection,
          storageEntity,
          storageData
        );
      } else {
        storageData.lastOutRate = 0;
        storageData.lastOutUpdateBlock = block.number;
        storageData.destination = bytes32(0);
        storageData.destinationDirection = BlockDirection.None;
        Storage.set(callerNamespace, storageEntity, storageData);
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