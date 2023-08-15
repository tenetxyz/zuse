// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { MindRegistry, MindRegistryTableId, VoxelTypeRegistryTableId, VoxelTypeRegistry, WorldRegistry, WorldRegistryTableId, WorldRegistryData } from "../codegen/Tables.sol";
import { Mind } from "@tenet-utils/src/Types.sol";

contract MindRegistrySystem is System {
  function registerMind(bytes32 voxelTypeId, Mind memory mind) public {
    registerMindForWorld(voxelTypeId, address(0), mind);
  }

  function registerMindForWorld(bytes32 voxelTypeId, address worldAddress, Mind memory mind) public {
    require(
      hasKey(VoxelTypeRegistryTableId, VoxelTypeRegistry.encodeKeyTuple(voxelTypeId)),
      "Voxel type ID has not been registered"
    );
    if (worldAddress != address(0)) {
      require(
        hasKey(WorldRegistryTableId, WorldRegistry.encodeKeyTuple(worldAddress)),
        "World address has not been registered"
      );
    }
    // Set creator
    mind.creator = tx.origin;

    Mind[] memory newMinds;
    if (hasKey(MindRegistryTableId, MindRegistry.encodeKeyTuple(voxelTypeId, worldAddress))) {
      bytes memory mindData = MindRegistry.get(voxelTypeId, worldAddress);
      Mind[] memory minds = abi.decode(mindData, (Mind[]));

      newMinds = new Mind[](minds.length + 1);
      for (uint256 i = 0; i < minds.length; i++) {
        require(minds[i].mindSelector != mind.mindSelector, "Mind already registered");
        newMinds[i] = minds[i];
      }
      newMinds[minds.length] = mind;
    } else {
      newMinds = new Mind[](1);
      newMinds[0] = mind;
    }

    MindRegistry.set(voxelTypeId, worldAddress, abi.encode(newMinds));
  }
}