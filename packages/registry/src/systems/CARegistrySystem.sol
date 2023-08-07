// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { CARegistry, CARegistryTableId, CARegistryData, VoxelTypeRegistry, VoxelTypeRegistryTableId, WorldRegistry, WorldRegistryTableId } from "../codegen/Tables.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { WORLD_NOTIFY_NEW_CA_VOXEL_TYPE_SIG } from "../Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

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

  function addVoxelToCA(bytes32 voxelTypeId) public {
    address caAddress = _msgSender();
    require(hasKey(CARegistryTableId, CARegistry.encodeKeyTuple(caAddress)), "CA has not been registered");
    require(
      hasKey(VoxelTypeRegistryTableId, VoxelTypeRegistry.encodeKeyTuple(voxelTypeId)),
      "Voxel type ID has not been registered"
    );

    CARegistryData memory caData = CARegistry.get(caAddress);
    require(caData.scale == VoxelTypeRegistry.getScale(voxelTypeId), "Voxel type must be the same scale as the CA");

    bytes32[] memory voxelTypeIds = caData.voxelTypeIds;
    for (uint256 i; i < voxelTypeIds.length; i++) {
      if (voxelTypeIds[i] == voxelTypeId) {
        revert("Voxel type has already been added to CA");
      }
    }

    bytes32[] memory updatedVoxelTypeIds = new bytes32[](voxelTypeIds.length + 1);
    for (uint256 i; i < voxelTypeIds.length; i++) {
      updatedVoxelTypeIds[i] = voxelTypeIds[i];
    }
    updatedVoxelTypeIds[voxelTypeIds.length] = voxelTypeId;

    CARegistry.setVoxelTypeIds(caAddress, updatedVoxelTypeIds);

    // Notify worlds using this CA that a new voxel type has been added
    bytes32[][] memory worlds = getKeysInTable(WorldRegistryTableId);
    for (uint256 i = 0; i < worlds.length; i++) {
      address world = address(uint160(uint256(worlds[i][0])));
      address[] memory worldCAs = WorldRegistry.getCaAddresses(world);
      for (uint256 j = 0; j < worldCAs.length; j++) {
        if (worldCAs[j] == caAddress) {
          safeCall(
            world,
            abi.encodeWithSignature(WORLD_NOTIFY_NEW_CA_VOXEL_TYPE_SIG, caAddress, voxelTypeId),
            "addVoxelToCA"
          );
        }
      }
    }
  }
}
