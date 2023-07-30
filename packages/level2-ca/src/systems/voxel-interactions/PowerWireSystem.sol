// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { SingleVoxelInteraction } from "@tenet-base-ca/src/prototypes/SingleVoxelInteraction.sol";
import { CAVoxelInteractionConfig, PowerWire, PowerWireData, Generator, GeneratorData, StorageData, Storage, Consumer, ConsumerData } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { BlockDirection } from "@tenet-utils/src/Types.sol";
import { entityIsPowerWire, entityIsGenerator, entityIsStorage, entityIsConsumer } from "@tenet-level2-ca/src/InteractionUtils.sol";
import { getOppositeDirection } from "@tenet-utils/src/VoxelCoordUtils.sol";

contract PowerWireSystem is SingleVoxelInteraction {
  function registerInteractionPowerWire() public {
    address world = _world();
    CAVoxelInteractionConfig.push(IWorld(world).eventHandlerPowerWire.selector);
  }

  function useGeneratorAsSource(
    address callerAddress,
    bytes32 generatorEntity,
    BlockDirection generatorBlockDirection,
    bytes32 powerWireEntity,
    PowerWireData memory powerWireData
  ) internal returns (bool changedEntity) {
    GeneratorData memory generatorData = Generator.get(callerAddress, generatorEntity);

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

    uint256 validTransferRate = powerWireData.transferRate;
    bool isBroken = powerWireData.isBroken;
    if (generatorData.genRate <= powerWireData.maxTransferRate) {
      validTransferRate = generatorData.genRate;
      isBroken = false;
    } else {
      validTransferRate = 0;
      isBroken = true;
    }

    if (
      !powerWireHasSource ||
      powerWireData.transferRate != validTransferRate ||
      powerWireData.isBroken != isBroken ||
      powerWireData.lastUpdateBlock != block.number
    ) {
      powerWireData.transferRate = validTransferRate;
      powerWireData.isBroken = isBroken;
      powerWireData.lastUpdateBlock = block.number;
      PowerWire.set(callerAddress, powerWireEntity, powerWireData);
      changedEntity = true;
    }
  }

  function usePowerWireAsSource(
    address callerAddress,
    bytes32 comparePowerWireEntity,
    BlockDirection comparePowerWireDirection,
    bytes32 powerWireEntity,
    PowerWireData memory powerWireData
  ) internal returns (bool changedEntity) {
    PowerWireData memory powerWireWithSourceData = PowerWire.get(callerAddress, comparePowerWireEntity);
    if (powerWireWithSourceData.source == bytes32(0) || powerWireWithSourceData.source == powerWireEntity) {
      // can't have a source if there is no source
      return false;
    }

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

    uint256 validTransferRate = powerWireData.transferRate;
    bool isBroken = powerWireData.isBroken;
    if (powerWireWithSourceData.transferRate <= powerWireData.maxTransferRate) {
      validTransferRate = powerWireWithSourceData.transferRate;
      isBroken = false;
    } else {
      validTransferRate = 0;
      isBroken = true;
    }

    if (
      !powerWireHasSource ||
      powerWireData.transferRate != validTransferRate ||
      powerWireData.isBroken != isBroken ||
      powerWireData.lastUpdateBlock != block.number
    ) {
      powerWireData.transferRate = validTransferRate;
      powerWireData.isBroken = isBroken;
      powerWireData.lastUpdateBlock = block.number;
      PowerWire.set(callerAddress, powerWireEntity, powerWireData);
      changedEntity = true;
    }
  }

  function usePowerWireAsDestination(
    address callerAddress,
    bytes32 comparePowerWireEntity,
    BlockDirection comparePowerWireDirection,
    bytes32 powerWireEntity,
    PowerWireData memory powerWireData
  ) internal returns (bool changedEntity) {
    PowerWireData memory powerWireWithDestinationData = PowerWire.get(callerAddress, comparePowerWireEntity);
    if (powerWireWithDestinationData.source == bytes32(0) || powerWireWithDestinationData.destination == bytes32(0)) {
      return false;
    }

    if (
      powerWireWithDestinationData.source != powerWireEntity ||
      powerWireWithDestinationData.sourceDirection != getOppositeDirection(comparePowerWireDirection)
    ) {
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
      powerWireData.lastUpdateBlock = block.number;
      PowerWire.set(callerAddress, powerWireEntity, powerWireData);
      changedEntity = true;
    }
  }

  function useStorageAsSource(
    address callerAddress,
    bytes32 storageEntity,
    BlockDirection storageBlockDirection,
    bytes32 powerWireEntity,
    PowerWireData memory powerWireData
  ) internal returns (bool changedEntity) {
    StorageData memory storageData = Storage.get(callerAddress, storageEntity);
    if (
      storageData.source == powerWireEntity ||
      storageData.energyStored == 0 ||
      (storageData.destination != bytes32(0) && storageData.destination != powerWireEntity)
    ) {
      // if the storage is already connected to a destination, then it can't be your source
      return false;
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

    uint256 validTransferRate = powerWireData.transferRate;
    bool isBroken = powerWireData.isBroken;
    if (storageData.outRate <= powerWireData.maxTransferRate) {
      validTransferRate = storageData.outRate;
      isBroken = false;
    } else {
      validTransferRate = 0;
      isBroken = true;
    }

    if (
      !powerWireHasSource ||
      powerWireData.transferRate != validTransferRate ||
      powerWireData.isBroken != isBroken ||
      powerWireData.lastUpdateBlock != block.number
    ) {
      powerWireData.transferRate = validTransferRate;
      powerWireData.isBroken = isBroken;
      powerWireData.lastUpdateBlock = block.number;
      PowerWire.set(callerAddress, powerWireEntity, powerWireData);
      changedEntity = true;
    }
  }

  function useStorageAsDestination(
    address callerAddress,
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
      StorageData memory storageData = Storage.get(callerAddress, storageEntity);
      if (storageData.source == bytes32(0) || storageData.source == powerWireEntity) {
        powerWireData.destination = storageEntity;
        powerWireData.destinationDirection = storageBlockDirection;
        powerWireData.lastUpdateBlock = block.number;
        PowerWire.set(callerAddress, powerWireEntity, powerWireData);
        changedEntity = true;
      } else {
        revert("PowerWireSystem: PowerWire is trying to make a storage with an existing source a destination");
      }
    }
  }

  function useConsumerAsDestination(
    address callerAddress,
    bytes32 consumerEntity,
    BlockDirection consumerBlockDirection,
    bytes32 powerWireEntity,
    PowerWireData memory powerWireData
  ) internal returns (bool changedEntity) {
    if (powerWireData.destination != bytes32(0)) {
      require(
        powerWireData.destination == consumerEntity && powerWireData.destinationDirection == consumerBlockDirection,
        "PowerWireSystem: PowerWire has a destination and is trying to connect to a different consumer destination"
      );
    } else {
      ConsumerData memory consumerData = Consumer.get(callerAddress, consumerEntity);
      if (consumerData.source == bytes32(0) || consumerData.source == powerWireEntity) {
        powerWireData.destination = consumerEntity;
        powerWireData.destinationDirection = consumerBlockDirection;
        powerWireData.lastUpdateBlock = block.number;
        PowerWire.set(callerAddress, powerWireEntity, powerWireData);
        changedEntity = true;
      } else {
        revert("PowerWireSystem: PowerWire is trying to become the source of a consumer with an existing source");
      }
    }
  }

  function runSingleInteraction(
    address callerAddress,
    bytes32 powerWireEntity,
    bytes32 compareEntity,
    BlockDirection compareBlockDirection
  ) internal override returns (bool changedEntity) {
    PowerWireData memory powerWireData = PowerWire.get(callerAddress, powerWireEntity);
    changedEntity = false;

    bool isPowerWire = entityIsPowerWire(callerAddress, compareEntity);
    bool isGenerator = entityIsGenerator(callerAddress, compareEntity);
    bool isStorage = entityIsStorage(callerAddress, compareEntity);
    bool isConsumer = entityIsConsumer(callerAddress, compareEntity);

    bool doesHaveSource = powerWireData.source != bytes32(0);

    if (!doesHaveSource) {
      if (isPowerWire) {
        changedEntity = usePowerWireAsSource(
          callerAddress,
          compareEntity,
          compareBlockDirection,
          powerWireEntity,
          powerWireData
        );
      } else if (isGenerator) {
        changedEntity = useGeneratorAsSource(
          callerAddress,
          compareEntity,
          compareBlockDirection,
          powerWireEntity,
          powerWireData
        );
      } else if (isStorage) {
        changedEntity = useStorageAsSource(
          callerAddress,
          compareEntity,
          compareBlockDirection,
          powerWireEntity,
          powerWireData
        );
      }
    } else {
      if (compareBlockDirection == powerWireData.sourceDirection) {
        if (entityIsGenerator(callerAddress, powerWireData.source)) {
          changedEntity = useGeneratorAsSource(
            callerAddress,
            compareEntity,
            compareBlockDirection,
            powerWireEntity,
            powerWireData
          );
        } else if (
          entityIsPowerWire(callerAddress, powerWireData.source) &&
          PowerWire.get(callerAddress, powerWireData.source).source != bytes32(0)
        ) {
          changedEntity = usePowerWireAsSource(
            callerAddress,
            compareEntity,
            compareBlockDirection,
            powerWireEntity,
            powerWireData
          );
        } else if (
          entityIsStorage(callerAddress, powerWireData.source) &&
          Storage.get(callerAddress, powerWireData.source).destination == powerWireEntity
        ) {
          changedEntity = useStorageAsSource(
            callerAddress,
            compareEntity,
            compareBlockDirection,
            powerWireEntity,
            powerWireData
          );
        } else {
          powerWireData.source = bytes32(0);
          powerWireData.transferRate = 0;
          powerWireData.sourceDirection = BlockDirection.None;
          powerWireData.destination = bytes32(0);
          powerWireData.destinationDirection = BlockDirection.None;
          powerWireData.lastUpdateBlock = block.number;
          PowerWire.set(callerAddress, powerWireEntity, powerWireData);
          changedEntity = true;
        }
      } else if (compareBlockDirection == powerWireData.destinationDirection) {
        // ie we have a destination
        // check if it still is a storage with source or a wire with destination
        if (
          entityIsStorage(callerAddress, powerWireData.destination) &&
          Storage.get(callerAddress, powerWireData.destination).source == powerWireEntity
        ) {
          changedEntity = useStorageAsDestination(
            callerAddress,
            compareEntity,
            compareBlockDirection,
            powerWireEntity,
            powerWireData
          );
        } else if (
          entityIsPowerWire(callerAddress, powerWireData.destination) &&
          PowerWire.get(callerAddress, powerWireData.destination).destination != bytes32(0)
        ) {
          changedEntity = usePowerWireAsDestination(
            callerAddress,
            compareEntity,
            compareBlockDirection,
            powerWireEntity,
            powerWireData
          );
        } else if (
          entityIsConsumer(callerAddress, powerWireData.destination) &&
          Consumer.get(callerAddress, powerWireData.destination).source == powerWireEntity
        ) {
          changedEntity = useConsumerAsDestination(
            callerAddress,
            compareEntity,
            compareBlockDirection,
            powerWireEntity,
            powerWireData
          );
        } else {
          powerWireData.destination = bytes32(0);
          powerWireData.destinationDirection = BlockDirection.None;
          powerWireData.lastUpdateBlock = block.number;
          PowerWire.set(callerAddress, powerWireEntity, powerWireData);
          changedEntity = true;
        }
      } else {
        if (isGenerator) {
          revert("PowerWireSystem: PowerWire has a source and is trying to connect to a different source");
        } else if (isStorage) {
          changedEntity = useStorageAsDestination(
            callerAddress,
            compareEntity,
            compareBlockDirection,
            powerWireEntity,
            powerWireData
          );
        } else if (isPowerWire) {
          changedEntity = usePowerWireAsDestination(
            callerAddress,
            compareEntity,
            compareBlockDirection,
            powerWireEntity,
            powerWireData
          );
        } else if (isConsumer) {
          changedEntity = useConsumerAsDestination(
            callerAddress,
            compareEntity,
            compareBlockDirection,
            powerWireEntity,
            powerWireData
          );
        }
      }
    }

    return changedEntity;
  }

  function entityShouldInteract(address callerAddress, bytes32 entityId) internal view override returns (bool) {
    return entityIsPowerWire(callerAddress, entityId);
  }

  function eventHandlerPowerWire(
    address callerAddress,
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {
    return super.eventHandler(callerAddress, centerEntityId, neighbourEntityIds, childEntityIds, parentEntity);
  }
}
