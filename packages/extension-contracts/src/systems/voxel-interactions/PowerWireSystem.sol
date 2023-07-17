// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SingleVoxelInteraction } from "@tenet-contracts/src/prototypes/SingleVoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { PowerWire, PowerWireData, Generator, GeneratorData, StorageData, Storage } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { registerExtension, entityIsPowerWire, entityIsGenerator, entityIsStorage } from "../../Utils.sol";
import { getOppositeDirection } from "@tenet-contracts/src/Utils.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

function combineStringWithBytes32(string memory a, bytes32 b) pure returns (string memory) {
  return string(abi.encodePacked(a, Strings.toHexString(uint256(b), 32)));
}

contract PowerWireSystem is SingleVoxelInteraction {
  function registerInteraction() public override {
    address world = _world();
    registerExtension(world, "PowerWireSystem", IWorld(world).extension_PowerWireSystem_eventHandler.selector);
  }

  function entityShouldInteract(bytes32 entityId, bytes16 callerNamespace) internal view override returns (bool) {
    return entityIsPowerWire(entityId, callerNamespace);
  }

  function useGenerateAsSource(
    bytes16 callerNamespace,
    bytes32 generatorEntity,
    BlockDirection generatorBlockDirection,
    bytes32 powerWireEntity,
    PowerWireData memory powerWireData
  ) internal returns (bool changedEntity) {
    GeneratorData memory generatorData = Generator.get(callerNamespace, generatorEntity);
    uint256 validTransferRate = generatorData.genRate <= powerWireData.maxTransferRate
      ? generatorData.genRate
      : powerWireData.maxTransferRate;

    bool powerWireHasSource = powerWireData.source != bytes32(0);
    if (powerWireHasSource) {
      require(
        generatorEntity == powerWireData.source && generatorBlockDirection == powerWireData.sourceDirection,
        "PowerWireSystem: source entity mismatch"
      );
    } else {
      powerWireData.source = generatorEntity;
      powerWireData.sourceDirection = generatorBlockDirection;
    }

    if (!powerWireHasSource || powerWireData.transferRate != validTransferRate) {
      powerWireData.transferRate = validTransferRate;
      PowerWire.set(callerNamespace, powerWireEntity, powerWireData);
      changedEntity = true;
    }
  }

  function usePowerWireAsSource(
    bytes16 callerNamespace,
    bytes32 comparePowerWireEntity,
    BlockDirection comparePowerWireDirection,
    bytes32 powerWireEntity,
    PowerWireData memory powerWireData
  ) internal returns (bool changedEntity) {
    PowerWireData memory powerWireWithSourceData = PowerWire.get(callerNamespace, comparePowerWireEntity);
    if (powerWireWithSourceData.source == bytes32(0)) {
      // can't have a source if there is no source
      return false;
    }
    uint256 validTransferRate = powerWireWithSourceData.transferRate <= powerWireData.maxTransferRate
      ? powerWireWithSourceData.transferRate
      : powerWireData.maxTransferRate;

    bool powerWireHasSource = powerWireData.source != bytes32(0);
    if (powerWireHasSource) {
      require(
        comparePowerWireEntity == powerWireData.source && comparePowerWireDirection == powerWireData.sourceDirection,
        "PowerWireSystem: source entity mismatch"
      );
    } else {
      powerWireData.source = comparePowerWireEntity;
      powerWireData.sourceDirection = comparePowerWireDirection;
    }

    if (!powerWireHasSource || powerWireData.transferRate != validTransferRate) {
      powerWireData.transferRate = validTransferRate;
      PowerWire.set(callerNamespace, powerWireEntity, powerWireData);
      changedEntity = true;
    }
  }

  function usePowerWireAsDestination(
    bytes16 callerNamespace,
    bytes32 comparePowerWireEntity,
    BlockDirection comparePowerWireDirection,
    bytes32 powerWireEntity,
    PowerWireData memory powerWireData
  ) internal returns (bool changedEntity) {
    PowerWireData memory powerWireWithDestinationData = PowerWire.get(callerNamespace, comparePowerWireEntity);
    if (powerWireWithDestinationData.source == bytes32(0) || powerWireWithDestinationData.destination == bytes32(0)) {
      return false;
    }

    if (powerWireWithDestinationData.sourceDirection != getOppositeDirection(comparePowerWireDirection)) {
      revert("PowerWireSystem: This power wire has a different source direction");
    }

    if (powerWireData.destination != bytes32(0)) {
      require(
        powerWireData.destination == comparePowerWireEntity &&
          powerWireData.destinationDirection == comparePowerWireDirection,
        "PowerWireSystem: PowerWire has a destination and is trying to connect to a different power wire destination"
      );
    } else {
      powerWireData.destination = comparePowerWireEntity;
      powerWireData.destinationDirection = comparePowerWireDirection;
      PowerWire.set(callerNamespace, powerWireEntity, powerWireData);
      changedEntity = true;
    }
  }

  function useStorageAsSource(
    bytes16 callerNamespace,
    bytes32 storageEntity,
    BlockDirection storageBlockDirection,
    bytes32 powerWireEntity,
    PowerWireData memory powerWireData
  ) internal returns (bool changedEntity) {
    StorageData memory storageData = Storage.get(callerNamespace, storageEntity);
    if (storageData.destination != bytes32(0) && storageData.destination != powerWireEntity) {
      // if the storage is already connected to a destination, then it can't be your source
      return false;
    }

    uint256 validTransferRate = 2 *
      (storageData.energyStored / (block.number - storageData.lastUpdateBlock)) -
      storageData.lastOutRate;
    if (validTransferRate > powerWireData.maxTransferRate) {
      validTransferRate = powerWireData.maxTransferRate;
    }

    bool powerWireHasSource = powerWireData.source != bytes32(0);
    if (powerWireHasSource) {
      require(
        storageEntity == powerWireData.source && storageBlockDirection == powerWireData.sourceDirection,
        "PowerWireSystem: source entity mismatch"
      );
    } else {
      powerWireData.source = storageEntity;
      powerWireData.sourceDirection = storageBlockDirection;
    }

    if (!powerWireHasSource || powerWireData.transferRate != validTransferRate) {
      powerWireData.transferRate = validTransferRate;
      PowerWire.set(callerNamespace, powerWireEntity, powerWireData);
      changedEntity = true;
    }
  }

  function useStorageAsDestination(
    bytes16 callerNamespace,
    bytes32 storageEntity,
    BlockDirection storageBlockDirection,
    bytes32 powerWireEntity,
    PowerWireData memory powerWireData
  ) internal returns (bool changedEntity) {
    if (powerWireData.destination != bytes32(0)) {
      require(
        powerWireData.destination == storageEntity && powerWireData.destinationDirection == storageBlockDirection,
        "PowerWireSystem: PowerWire has a destination and is trying to connect to a different storage destination"
      );
    } else {
      StorageData memory storageData = Storage.get(callerNamespace, storageEntity);
      if (storageData.source == bytes32(0) || storageData.source == powerWireEntity) {
        powerWireData.destination = storageEntity;
        powerWireData.destinationDirection = storageBlockDirection;
        PowerWire.set(callerNamespace, powerWireEntity, powerWireData);
        changedEntity = true;
      } else {
        revert("PowerWireSystem: PowerWire is trying to make a storage with an existing source a destination");
      }
    }
  }

  function runSingleInteraction(
    bytes16 callerNamespace,
    bytes32 signalEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    PowerWireData memory powerWireData = PowerWire.get(callerNamespace, signalEntity);
    changedEntity = false;

    bool isPowerWire = entityIsPowerWire(compareEntity, callerNamespace);
    bool isGenerator = entityIsGenerator(compareEntity, callerNamespace);
    bool isStorage = entityIsStorage(compareEntity, callerNamespace);

    bool doesHaveSource = powerWireData.source != bytes32(0);

    if (!doesHaveSource) {
      if (isPowerWire) {
        changedEntity = usePowerWireAsSource(
          callerNamespace,
          compareEntity,
          compareBlockDirection,
          signalEntity,
          powerWireData
        );
      } else if (isGenerator) {
        changedEntity = useGenerateAsSource(
          callerNamespace,
          compareEntity,
          compareBlockDirection,
          signalEntity,
          powerWireData
        );
      } else if (isStorage) {
        changedEntity = useStorageAsSource(
          callerNamespace,
          compareEntity,
          compareBlockDirection,
          signalEntity,
          powerWireData
        );
      }
    } else {
      if (compareBlockDirection == powerWireData.sourceDirection) {
        if (entityIsGenerator(powerWireData.source, callerNamespace)) {
          changedEntity = useGenerateAsSource(
            callerNamespace,
            compareEntity,
            compareBlockDirection,
            signalEntity,
            powerWireData
          );
        } else if (
          entityIsPowerWire(powerWireData.source, callerNamespace) &&
          PowerWire.get(callerNamespace, powerWireData.source).source != bytes32(0)
        ) {
          changedEntity = usePowerWireAsSource(
            callerNamespace,
            compareEntity,
            compareBlockDirection,
            signalEntity,
            powerWireData
          );
        } else if (
          entityIsStorage(powerWireData.source, callerNamespace) &&
          Storage.get(callerNamespace, powerWireData.source).destination == signalEntity
        ) {
          changedEntity = useStorageAsSource(
            callerNamespace,
            compareEntity,
            compareBlockDirection,
            signalEntity,
            powerWireData
          );
        } else {
          powerWireData.source = bytes32(0);
          powerWireData.transferRate = 0;
          powerWireData.sourceDirection = BlockDirection.None;
          powerWireData.destination = bytes32(0);
          powerWireData.destinationDirection = BlockDirection.None;
          PowerWire.set(callerNamespace, signalEntity, powerWireData);
          changedEntity = true;
        }
      } else if (compareBlockDirection == powerWireData.destinationDirection) {
        // ie we have a destination
        // check if it still is a storage with source or a wire with destination
        if (
          entityIsStorage(powerWireData.destination, callerNamespace) &&
          Storage.get(callerNamespace, powerWireData.destination).source == signalEntity
        ) {
          changedEntity = useStorageAsDestination(
            callerNamespace,
            compareEntity,
            compareBlockDirection,
            signalEntity,
            powerWireData
          );
        } else if (
          entityIsPowerWire(powerWireData.destination, callerNamespace) &&
          PowerWire.get(callerNamespace, powerWireData.destination).destination != bytes32(0)
        ) {
          changedEntity = usePowerWireAsDestination(
            callerNamespace,
            compareEntity,
            compareBlockDirection,
            signalEntity,
            powerWireData
          );
        } else {
          powerWireData.destination = bytes32(0);
          powerWireData.destinationDirection = BlockDirection.None;
          PowerWire.set(callerNamespace, signalEntity, powerWireData);
          changedEntity = true;
        }
      } else {
        if (isGenerator) {
          revert("PowerWireSystem: PowerWire has a source and is trying to connect to a different source");
        } else if (isStorage) {
          changedEntity = useStorageAsDestination(
            callerNamespace,
            compareEntity,
            compareBlockDirection,
            signalEntity,
            powerWireData
          );
        } else if (isPowerWire) {
          changedEntity = usePowerWireAsDestination(
            callerNamespace,
            compareEntity,
            compareBlockDirection,
            signalEntity,
            powerWireData
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
