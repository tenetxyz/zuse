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

  function runSingleInteraction(
    bytes16 callerNamespace,
    bytes32 signalEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    StorageData memory storageData = Storage.get(callerNamespace, signalEntity);
    changedEntity = false;

    bool isPowerWire = entityIsPowerWire(compareEntity, callerNamespace);

    bool isSourceWire = isPowerWire &&
      PowerWire.get(callerNamespace, compareEntity).transferRate > 0 &&
      PowerWire.get(callerNamespace, compareEntity).source != bytes32(0);

    bool isWithoutSourceWire = isPowerWire &&
      PowerWire.get(callerNamespace, compareEntity).transferRate == 0 &&
      PowerWire.get(callerNamespace, compareEntity).source == bytes32(0);

    bool doesHaveSource = storageData.lastInRate != 0;
    bool doesHaveDestination = storageData.lastOutRate != 0;

    if (!doesHaveSource) {
      if (isSourceWire) {
        PowerWireData memory sourceWireData = PowerWire.get(callerNamespace, compareEntity);
        uint256 newEnergyToStore = ((sourceWireData.transferRate + storageData.lastInRate) / 2) *
          (block.number - storageData.lastUpdateBlock);
        uint256 proposedEnergyStored = newEnergyToStore + storageData.energyStored;

        storageData.energyStored = (proposedEnergyStored > storageData.maxStorage)
          ? storageData.maxStorage
          : proposedEnergyStored;
        storageData.lastInRate = sourceWireData.transferRate;
        storageData.lastUpdateBlock = block.number;
        storageData.source = compareEntity;
        storageData.sourceDirection = compareBlockDirection;
        Storage.set(callerNamespace, signalEntity, storageData);

        changedEntity = true;
      }
    } else {
      if (compareBlockDirection == storageData.sourceDirection) {
        if (!isSourceWire) {
          if (storageData.lastUpdateBlock != block.number) {
            storageData.lastInRate = 0;
            storageData.lastUpdateBlock = block.number;
            storageData.source = bytes32(0);
            storageData.sourceDirection = BlockDirection.None;
            Storage.set(callerNamespace, signalEntity, storageData);
          }
        }
      }
      if (compareBlockDirection == storageData.destinationDirection) {
        if (!isPowerWire) {
          if (storageData.lastUpdateBlock != block.number) {
            storageData.lastOutRate = 0;
            storageData.lastUpdateBlock = block.number;
            storageData.destination = bytes32(0);
            storageData.destinationDirection = BlockDirection.None;
            Storage.set(callerNamespace, signalEntity, storageData);
          }
        }
      } else {
        if (isPowerWire) {
          if (isSourceWire) {
            revert("StorageSystem: Storage has a source and is trying to connect to a different source");
          } else if (isWithoutSourceWire) {
            if (storageData.destination == bytes(0)) {
              // this will be our destination!
              PowerWireData memory destWireData = PowerWire.get(callerNamespace, compareEntity);
              uint256 validTransferRate = 2 *
                (storageData.energyStored / (block.number - storageData.lastUpdateBlock)) -
                storageData.lastOutRate;
              if (validTransferRate > destWireData.maxTransferRate) {
                validTransferRate = destWireData.maxTransferRate;
              }
              uint256 energyToLeave = ((storageData.lastOutRate + validTransferRate) / 2) *
                (block.number - storageData.lastUpdateBlock);

              storageData.energyStored = storageData.energyStored - energyToLeave;
              storageData.lastOutRate = validTransferRate;
              storageData.lastUpdateBlock = block.number;
              storageData.destination = compareEntity;
              storageData.destinationDirection = compareBlockDirection;
              Storage.set(callerNamespace, signalEntity, storageData);

              changedEntity = true;
            } else {
              revert("StorageSystem: Storage has a destination and is trying to connect to a different destination");
            }
          }
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
