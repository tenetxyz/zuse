// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SingleVoxelInteraction } from "@tenet-contracts/src/prototypes/SingleVoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { PowerWire, PowerWireData, Storage, StorageData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { registerExtension, entityIsStorage, entityIsPowerWire } from "../../Utils.sol";
import { getOppositeDirection } from "@tenet-contracts/src/Utils.sol";
import { BlockHeightUpdate } from "@tenet-contracts/src/Types.sol";

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

    BlockHeightUpdate memory inBlockHeightUpdate = abi.decode(storageData.inBlockHeightUpdate, (BlockHeightUpdate));

    if (
      !storageHasSource ||
      storageData.inRate != sourceWireData.transferRate ||
      inBlockHeightUpdate.lastUpdateBlock != block.number
    ) {
      uint256 newEnergyToStore = ((sourceWireData.transferRate + storageData.inRate) / 2) *
        inBlockHeightUpdate.blockHeightDelta;
      uint256 proposedEnergyStored = newEnergyToStore + storageData.energyStored;
      uint256 newEnergyStored = (proposedEnergyStored > storageData.maxStorage)
        ? storageData.maxStorage
        : proposedEnergyStored;

      storageData.energyStored = newEnergyStored;
      storageData.inRate = sourceWireData.transferRate;
      inBlockHeightUpdate.lastUpdateBlock = block.number;
      storageData.inBlockHeightUpdate = abi.encode(inBlockHeightUpdate);
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
    if (storageData.source == powerWireEntity) {
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

    uint256 validTransferRate = storageData.outRate;
    BlockHeightUpdate memory outBlockHeightUpdate = abi.decode(storageData.outBlockHeightUpdate, (BlockHeightUpdate));
    // so we don't divide by zero
    if (outBlockHeightUpdate.blockHeightDelta != 0) {
      validTransferRate = 2 * (storageData.energyStored / outBlockHeightUpdate.blockHeightDelta);
    }

    if (!storageHasDestination || storageData.outRate != validTransferRate) {
      if (validTransferRate <= storageData.outRate) {
        validTransferRate = 0;
      } else {
        validTransferRate -= storageData.outRate;
      }
      if (validTransferRate > destinationWireData.maxTransferRate) {
        validTransferRate = destinationWireData.maxTransferRate;
      }

      uint256 energyToLeave = ((storageData.outRate + validTransferRate) / 2) * (outBlockHeightUpdate.blockHeightDelta);
      uint256 newEnergyStored = storageData.energyStored;
      if (newEnergyStored <= energyToLeave) {
        newEnergyStored = 0;
      } else {
        newEnergyStored -= energyToLeave;
      }

      storageData.energyStored = newEnergyStored;
      storageData.outRate = validTransferRate;
      outBlockHeightUpdate.lastUpdateBlock = block.number;
      storageData.outBlockHeightUpdate = abi.encode(outBlockHeightUpdate);
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

    BlockHeightUpdate memory inBlockHeightUpdate = abi.decode(storageData.inBlockHeightUpdate, (BlockHeightUpdate));
    if (inBlockHeightUpdate.blockNumber != block.number) {
      inBlockHeightUpdate.blockNumber = block.number;
      inBlockHeightUpdate.blockHeightDelta = block.number - inBlockHeightUpdate.lastUpdateBlock;
      storageData.inBlockHeightUpdate = abi.encode(inBlockHeightUpdate);
      Storage.set(callerNamespace, storageEntity, storageData);
    }

    BlockHeightUpdate memory outBlockHeightUpdate = abi.decode(storageData.outBlockHeightUpdate, (BlockHeightUpdate));
    if (outBlockHeightUpdate.blockNumber != block.number) {
      outBlockHeightUpdate.blockNumber = block.number;
      outBlockHeightUpdate.blockHeightDelta = block.number - outBlockHeightUpdate.lastUpdateBlock;
      storageData.outBlockHeightUpdate = abi.encode(outBlockHeightUpdate);
      Storage.set(callerNamespace, storageEntity, storageData);
    }

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
        storageData.inRate = 0;
        inBlockHeightUpdate.lastUpdateBlock = block.number;
        storageData.inBlockHeightUpdate = abi.encode(inBlockHeightUpdate);
        storageData.source = bytes32(0);
        storageData.sourceDirection = BlockDirection.None;
        Storage.set(callerNamespace, storageEntity, storageData);
        changedEntity = true;
      }
    }

    if ((isEnergyStored || doesHaveSource) && !doesHaveDest) {
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
        storageData.outRate = 0;
        outBlockHeightUpdate.lastUpdateBlock = block.number;
        storageData.outBlockHeightUpdate = abi.encode(outBlockHeightUpdate);
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
