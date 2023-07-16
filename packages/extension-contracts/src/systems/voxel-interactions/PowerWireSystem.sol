// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SingleVoxelInteraction } from "@tenet-contracts/src/prototypes/SingleVoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { PowerWire, PowerWireData, Generator, GeneratorData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { registerExtension, entityIsPowerWire, entityIsGenerator, entityIsStorage } from "../../Utils.sol";
import { getOppositeDirection } from "@tenet-contracts/src/Utils.sol";

contract PowerWireSystem is SingleVoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    registerExtension(world, "PowerWireSystem", IWorld(world).extension_PowerWireSystem_eventHandler.selector);
  }

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view override returns (bool) {
    return entityIsPowerWire(entityId, callerNamespace);
  }

  bool isStorageWithSourceAndWithoutDest(bytes32 entityId, bytes16 callerNamespace) {
    StorageData memory storageData = Storage.get(callerNamespace, entityId);
    return storageData.source != bytes32(0) && storageData.destination == bytes32(0);
  }

    bool isStorageWithSourceWithDest(bytes32 entityId, bytes16 callerNamespace, bytes32 destination) {
    StorageData memory storageData = Storage.get(callerNamespace, entityId);
    return storageData.source != bytes32(0) && storageData.destination == destination;
  }

  function runSingleInteraction(
    bytes16 callerNamespace,
    bytes32 signalEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    PowerWireData memory powerWireData = PowerWire.get(callerNamespace, signalEntity);
    changedEntity = false;

    bool isPowerWire = entityIsPowerWire(compareEntity, callerNamespace) &&
      PowerWire.get(callerNamespace, compareEntity).transferRate > 0;
    bool isGenerator = entityIsGenerator(compareEntity, callerNamespace);
    bool isStorage = entityIsStorage(compareEntity, callerNamespace);
    bool isCompareStorageWithSourceAndWithoutDest = false;
    if (isStorage) {
      isCompareStorageWithSourceAndWithoutDest = isStorageWithSourceAndWithoutDest(compareEntity, callerNamespace);
    }

    bool doesHaveSource = powerWireData.source != bytes32(0);
    bool doesHaveDestination = powerWireData.destination != bytes32(0);

    if (!doesHaveSource) {
      if (isPowerWire) {
        PowerWireData memory neighPowerWireData = PowerWire.get(callerNamespace, compareEntity);
        uint256 validTransferRate = neighPowerWireData.transferRate <= powerWireData.maxTransferRate
          ? neighPowerWireData.transferRate
          : powerWireData.maxTransferRate;

        powerWireData.source = compareEntity;
        powerWireData.transferRate = validTransferRate;
        powerWireData.sourceDirection = neighPowerWireData.direction;
        PowerWire.set(callerNamespace, signalEntity, powerWireData);
        changedEntity = true;
      } else if (isGenerator) {
        GeneratorData memory generatorData = Generator.get(callerNamespace, compareEntity);
        uint256 validTransferRate = generatorData.genRate <= powerWireData.maxTransferRate
          ? generatorData.genRate
          : powerWireData.maxTransferRate;

        powerWireData.source = compareEntity;
        powerWireData.transferRate = validTransferRate;
        powerWireData.sourceDirection = compareBlockDirection;
        PowerWire.set(callerNamespace, signalEntity, powerWireData);
        changedEntity = true;
      } else if (isStorage && isCompareStorageWithSourceAndWithoutDest) {
        // become the destination of the storage
        StorageData memory storageData = Storage.get(callerNamespace, compareEntity);
        uint256 validTransferRate = 2 *
          (storageData.energyStored / (block.number - storageData.lastUpdateBlock)) -
          storageData.lastOutRate;
        if (validTransferRate > powerWireData.maxTransferRate) {
          validTransferRate = powerWireData.maxTransferRate;
        }

        powerWireData.source = compareEntity;
        powerWireData.sourceDirection = compareBlockDirection;
        powerWireData.transferRate = validTransferRate;
        PowerWire.set(callerNamespace, signalEntity, powerWireData);
        changedEntity = true;
      }
    } else {
      if (compareBlockDirection == powerWireData.sourceDirection) {
        if (entityIsGenerator(powerWireData.source, callerNamespace)) {
          GeneratorData memory generatorData = Generator.get(callerNamespace, compareEntity);
          uint256 validTransferRate = generatorData.genRate <= powerWireData.maxTransferRate
            ? generatorData.genRate
            : powerWireData.maxTransferRate;

          if (powerWireData.transferRate != validTransferRate) {
            powerWireData.transferRate = validTransferRate;
            PowerWire.set(callerNamespace, signalEntity, powerWireData);
            changedEntity = true;
          }
        } else if (
          entityIsPowerWire(powerWireData.source, callerNamespace) &&
          PowerWire.get(callerNamespace, powerWireData.source).transferRate > 0
        ) {
          PowerWireData memory neighPowerWireData = PowerWire.get(callerNamespace, compareEntity);
          uint256 validTransferRate = neighPowerWireData.transferRate <= powerWireData.maxTransferRate
            ? neighPowerWireData.transferRate
            : powerWireData.maxTransferRate;

          if (powerWireData.transferRate != validTransferRate) {
            powerWireData.transferRate = validTransferRate;
            PowerWire.set(callerNamespace, signalEntity, powerWireData);
            changedEntity = true;
          }
        } else if (entityIsStorage(powerWireData.source, callerNamespace) && isStorageWithSourceWithDest(compareEntity, callerNamespace, signalEntity)) {
          StorageData memory storageData = Storage.get(callerNamespace, powerWireData.source);
          uint256 validTransferRate = 2 *
            (storageData.energyStored / (block.number - storageData.lastUpdateBlock)) -
            storageData.lastOutRate;
          if (validTransferRate > powerWireData.maxTransferRate) {
            validTransferRate = powerWireData.maxTransferRate;
          }

          if(powerWireData.transferRate != validTransferRate){
            powerWireData.transferRate = validTransferRate;
            PowerWire.set(callerNamespace, signalEntity, powerWireData);
            changedEntity = true;
          }
        } else {
          powerWireData.source = bytes32(0);
          powerWireData.transferRate = 0;
          powerWireData.sourceDirection = BlockDirection.None;
          PowerWire.set(callerNamespace, signalEntity, powerWireData);
          changedEntity = true;
        }
      } else {
        if (isGenerator) {
          revert("PowerWireSystem: PowerWire has a source and is trying to connect to a different source");
        } else if (isStorage) {
          // this is our destination


        } else if (isPowerWire) {
          PowerWireData memory neighPowerWireData = PowerWire.get(callerNamespace, compareEntity);
          if (
            neighPowerWireData.transferRate > 0 &&
            neighPowerWireData.sourceDirection != getOppositeDirection(compareBlockDirection)
          ) {
            // if we are not the source of this active wire
            revert("PowerWireSystem: PowerWire has a source and is trying to connect to a different source");
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
