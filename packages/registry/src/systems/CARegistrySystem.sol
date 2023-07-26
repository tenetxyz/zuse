// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { CARegistry, CARegistryTableId, CARegistryData, VoxelTypeRegistry, VoxelTypeRegistryTableId } from "../codegen/Tables.sol";

contract CARegistrySystem is System {
  // TODO: How do we know this CA is using these voxel types?
  function registerCA(string memory name, string memory description, bytes32[] memory voxelTypeIds) public {
    require(bytes(name).length > 0, "Name cannot be empty");
    require(bytes(description).length > 0, "Description cannot be empty");
    require(voxelTypeIds.length > 0, "Must have at least one voxel type");

    uint32 scale = 0;
    for (uint256 i; i < voxelTypeIds.length; i++) {
      require(
        hasKey(VoxelTypeRegistryTableId, VoxelTypeRegistry.encodeKeyTuple(voxelTypeIds[i])),
        "Voxel type ID has not been registered"
      );
      if (scale == 0) {
        scale = VoxelTypeRegistry.getScale(voxelTypeIds[i]);
      } else {
        require(scale == VoxelTypeRegistry.getScale(voxelTypeIds[i]), "All voxel types must be the same scale");
      }
    }

    address caAddress = _msgSender();
    require(!hasKey(CARegistryTableId, CARegistry.encodeKeyTuple(caAddress)), "CA has already been registered");

    CARegistry.set(
      caAddress,
      CARegistryData({
        name: name,
        description: description,
        creator: tx.origin,
        scale: scale,
        voxelTypeIds: voxelTypeIds
      })
    );
  }
}
