// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData, VoxelTypeRegistryTableId, VoxelVariantsRegistry, VoxelVariantsRegistryData, VoxelVariantsRegistryTableId } from "../codegen/Tables.sol";

contract CARegistrySystem is System {
  // TODO: How do we know this CA is using these voxel types?
  function registerCA(string memory name, string memory description, bytes32[] memory voxelTypeIds) public {
    require(bytes(name).length > 0, "Name cannot be empty");
    require(bytes(description).length > 0, "Description cannot be empty");
    require(voxelTypeIds.length > 0, "Must have at least one voxel type");

    for (uint256 i; i < voxelTypeIds.length; i++) {
      require(
        hasKey(VoxelTypeRegistryTableId, VoxelTypeRegistry.encodeKeyTuple(voxelTypeIds[i])),
        "Voxel type ID has not been registered"
      );
    }

    address caAddress = msg.sender;
    require(caAddress == 0x9A9f2CCfdE556A7E9Ff0848998Aa4a0CFD8863AE, "Only the CA can register itself");
  }
}
