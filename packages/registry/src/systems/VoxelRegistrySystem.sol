// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData, VoxelTypeRegistryTableId, VoxelVariantsRegistry, VoxelVariantsRegistryData, VoxelVariantsRegistryTableId } from "../codegen/Tables.sol";

contract VoxelRegistrySystem is System {
  function registerVoxelType(
    string memory voxelTypeName,
    bytes32 voxelTypeId,
    bytes32 previewVoxelVariantId,
    address caAddress
  ) public {
    require(caAddress != address(0), "CA address cannot be empty");
    // TODO: Add some more checks on caAddress
    bytes32[] memory voxelTypeKeyTuple = new bytes32[](1);
    voxelTypeKeyTuple[0] = voxelTypeId;
    require(!hasKey(VoxelTypeRegistryTableId, voxelTypeKeyTuple), "Voxel type ID has already been registered");
    bytes32[] memory voxelVariantKeyTuple = new bytes32[](1);
    voxelVariantKeyTuple[0] = previewVoxelVariantId;
    require(
      hasKey(VoxelVariantsRegistryTableId, voxelVariantKeyTuple),
      "Preview voxel variant ID has not been registered"
    );
    require(bytes(voxelTypeName).length > 0, "Name cannot be empty");

    VoxelTypeRegistry.set(
      voxelTypeId,
      VoxelTypeRegistryData({
        caAddress: caAddress,
        previewVoxelVariantId: previewVoxelVariantId,
        creator: tx.origin,
        numSpawns: 0,
        name: voxelTypeName
      })
    );
  }

  function registerVoxelVariant(bytes32 voxelVariantId, VoxelVariantsRegistryData memory voxelVariant) public {
    bytes32[] memory voxelVariantKeyTuple = new bytes32[](1);
    voxelVariantKeyTuple[0] = voxelVariantId;
    require(
      !hasKey(VoxelVariantsRegistryTableId, voxelVariantKeyTuple),
      "Voxel variant ID has already been registered"
    );

    bytes32[][] memory variants = getKeysInTable(VoxelVariantsRegistryTableId);
    uint256 voxelVariantIdCounter = variants.length;
    voxelVariant.variantId = voxelVariantIdCounter;
    VoxelVariantsRegistry.set(voxelVariantId, voxelVariant);
  }
}
