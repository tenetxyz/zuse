// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { OwnedBy, VoxelType, Spawn } from "../codegen/Tables.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { addressToEntityKey } from "../Utils.sol";

// sets the entity as a spawn interface for the given spawn
contract SetSpawnInterfaceSystem is System {
  function setSpawnInterface(bytes32 spawnId, bytes32 entity, bool setAsInterface) public {
    // TODO: we should only allow the owner of the spawn call this system

    bytes32[] memory interfaceVoxels = Spawn.getInterfaceVoxels(spawnId);
    if (setAsInterface) {
      for (uint32 i = 0; i < interfaceVoxels.length; i++) {
        if (interfaceVoxels[i] == entity) {
          // the entity is already in the interface array. so do nothing
          return;
        }
      }

      // we need to add the entity to the interface array
      Spawn.pushInterfaceVoxels(spawnId, entity);
    } else {
      // check to see if this entitiy is already an interface. If it is, remove it from the array
      bytes32[] memory newInterfaceVoxels = new bytes32[](interfaceVoxels.length - 1);

      uint32 i = 0; // This is the index we're writing to the newInterfaceVoxels array.
      uint32 j = 0;
      for (; j < interfaceVoxels.length; j++) {
        if (interfaceVoxels[j] != entity) {
          newInterfaceVoxels[i] = interfaceVoxels[j];
          i++;
        }
      }

      bool useNewArray = i != j;
      if (useNewArray) {
        Spawn.setInterfaceVoxels(spawnId, newInterfaceVoxels);
      }
      // else do nothing. The array already didn't have the entity!
    }
  }
}
