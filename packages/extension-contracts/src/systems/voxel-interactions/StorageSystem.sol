// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { SingleVoxelInteraction } from "@tenet-contracts/src/prototypes/SingleVoxelInteraction.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { PowerWire, PowerWireData, Storage, StorageData } from "../../codegen/Tables.sol";
import { BlockDirection } from "../../codegen/Types.sol";
import { registerExtension, entityIsStorage } from "../../Utils.sol";
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

    StorageData memory storageData = StorageData.get(callerNamespace, signalEntity);
    changedEntity = false;

    bool isSourceWire = entityIsPowerWire(compareEntity, callerNamespace) &&
          PowerWire.get(callerNamespace, compareEntity).transferRate > 0 &&
          PowerWire.get(callerNamespace, compareEntity).source != bytes32(0);
    
    bool isDestinationWire = entityIsPowerWire(compareEntity, callerNamespace) &&
          PowerWire.get(callerNamespace, compareEntity).transferRate = 0 &&
          PowerWire.get(callerNamespace, compareEntity).destination != bytes32(0);


    bool doesHaveSource = storageData.lastInRate != 0;
    bool doesHaveDestination = storageData.lastOutRate != 0;

  if (!doesHaveSource) {
    if (isSourceWire && storageData.lastUpdateBlock != block.number) {
      PowerWireData memory sourceWireData = PowerWire.get(callerNamespace, compareEntity);
      uint256 newEnergyToStore = (sourceWireData.transferRate + storageData.lastInRate) / 2 * (block.number - storageData.lastUpdateBlock);
      uint256 proposedEnergyStored = newEnergyToStore + storageData.energyStored;
      
      storageData.energyStored = (proposedEnergyStored > storageData.maxStorage) ? storageData.maxStorage : proposedEnergyStored;
      storageData.lastInRate = sourceWireData.transferRate;
      storageData.lastUpdateBlock = block.number;
      storageData.source = compareEntity;
      storageData.sourceDirection = compareBlockDirection;
      Storage.set(callerNamespace, signalEntity, storageData);
      
      sourceWireData.destination = signalEntity;
      PowerWire.set(callerNamespace, compareEntity, sourceWireData);
      
      changedEntity = true;
    }
  } else if (doesHaveSource) {
    if (isSourceWire && storageData.lastUpdateBlock != block.number) {
      revert("StorageSystem: Storage has a source and is trying to connect to a different source");
    }
  }

  if (!doesHaveDestination) {
    if (isDestinationWire && storageData.lastUpdateBlock != block.number) {
      PowerWireData memory destWireData = PowerWire.get(callerNamespace, compareEntity);
      uint256 validTransferRate = 2 * (storageData.energyStored / ( block.number - storageData.lastUpdateBlock ) ) - storageData.lastOutRate;
      if (validTransferRate > destWireData.maxTransferRate) { validTransferRate = destWireData.maxTransferRate; }
      uint256 energyToLeave = (storageData.lastOutRate + validTransferRate) / 2 * ( block.number - storageData.lastUpdateBlock );

      storageData.energyStored = storageData.energyStored - energyToLeave;
      storageData.lastOutRate = validTransferRate;
      storageData.lastUpdateBlock = block.number;
      storageData.destination = compareEntity;
      storageData.destinationDirection = compareBlockDirection;
      Storage.set(callerNamespace, signalEntity, storageData);

      destWireData.source = signalEntity;
      destWireData.transferRate = validTransferRate;
      PowerWire.set(callerNamespace, compareEntity, destWireData);

      changedEntity = true;
    } 
  } else if (doesHaveDestination) {
    if (isDestinationWire && storageData.lastUpdateBlock != block.number) {
      revert("StorageSystem: Storage has a destination and is trying to connect to a different destination");
    }
  }

if (doesHaveSource) {

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
