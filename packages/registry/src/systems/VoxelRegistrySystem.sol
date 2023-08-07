// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData, VoxelTypeRegistryTableId, VoxelVariantsRegistry, VoxelVariantsRegistryData, VoxelVariantsRegistryTableId } from "../codegen/Tables.sol";
import { entityArraysAreEqual } from "@tenet-utils/src/Utils.sol";

contract VoxelRegistrySystem is System {
  function registerVoxelType(
    string memory voxelTypeName,
    bytes32 voxelTypeId,
    bytes32 baseVoxelTypeId,
    bytes32[] memory childVoxelTypeIds,
    bytes32[] memory schemaVoxelTypeIds,
    bytes32 previewVoxelVariantId,
    address caAddress
  ) public {
    require(
      !hasKey(VoxelTypeRegistryTableId, VoxelTypeRegistry.encodeKeyTuple(voxelTypeId)),
      "Voxel type ID has already been registered"
    );
    require(
      hasKey(VoxelVariantsRegistryTableId, VoxelVariantsRegistry.encodeKeyTuple(previewVoxelVariantId)),
      "Preview voxel variant ID has not been registered"
    );
    require(bytes(voxelTypeName).length > 0, "Name cannot be empty");

    uint32 scale;
    if (childVoxelTypeIds.length == 1) {
      scale = 1;
      require(
        childVoxelTypeIds[0] == voxelTypeId,
        "Child voxel type ID must be the same as parent voxel type ID for scale 1"
      );
    } else if (childVoxelTypeIds.length == 8) {
      for (uint256 i; i < childVoxelTypeIds.length; i++) {
        if (childVoxelTypeIds[i] == 0) {
          continue;
        }
        require(
          hasKey(VoxelTypeRegistryTableId, VoxelTypeRegistry.encodeKeyTuple(childVoxelTypeIds[i])),
          "Child voxel type ID has not been registered"
        );
        if (scale == 0) {
          scale = VoxelTypeRegistry.getScale(childVoxelTypeIds[i]) + 1;
        } else {
          require(
            scale == VoxelTypeRegistry.getScale(childVoxelTypeIds[i]) + 1,
            "All voxel types must be the same scale"
          );
        }
      }
    } else {
      revert("Invalid number of child voxel types");
    }

    if (schemaVoxelTypeIds.length == 1) {
      require(
        schemaVoxelTypeIds[0] == voxelTypeId,
        "Schemal voxel type ID must be the same as parent voxel type ID for scale 1"
      );
    } else if (childVoxelTypeIds.length == 8) {
      // TODO: Add more checks on schemaVoxelTypeIds
      for (uint256 i; i < schemaVoxelTypeIds.length; i++) {
        if (schemaVoxelTypeIds[i] == 0) {
          continue;
        }
        require(
          hasKey(VoxelTypeRegistryTableId, VoxelTypeRegistry.encodeKeyTuple(schemaVoxelTypeIds[i])),
          "Schema voxel type ID has not been registered"
        );
      }
    } else {
      revert("Invalid number of schema voxel types");
    }

    if (baseVoxelTypeId != voxelTypeId) {
      // otherwise, this is a base voxel type, so we don't need any checks
      require(
        hasKey(VoxelTypeRegistryTableId, VoxelTypeRegistry.encodeKeyTuple(baseVoxelTypeId)),
        "Base voxel type ID has not been registered"
      );

      require(scale == VoxelTypeRegistry.getScale(baseVoxelTypeId), "Base voxel type must be the same scale");

      require(
        entityArraysAreEqual(childVoxelTypeIds, VoxelTypeRegistry.getChildVoxelTypeIds(baseVoxelTypeId)),
        "Child voxel type IDs must be the same as base"
      );
      require(
        entityArraysAreEqual(schemaVoxelTypeIds, VoxelTypeRegistry.getSchemaVoxelTypeIds(baseVoxelTypeId)),
        "Schema voxel type IDs must be the same as base"
      );
    }

    VoxelTypeRegistry.set(
      voxelTypeId,
      VoxelTypeRegistryData({
        baseVoxelTypeId: baseVoxelTypeId,
        childVoxelTypeIds: childVoxelTypeIds,
        schemaVoxelTypeIds: schemaVoxelTypeIds,
        previewVoxelVariantId: previewVoxelVariantId,
        caAddress: caAddress,
        creator: tx.origin,
        scale: scale,
        numSpawns: 0,
        name: voxelTypeName
      })
    );
  }

  function registerVoxelVariant(bytes32 voxelVariantId, VoxelVariantsRegistryData memory voxelVariant) public {
    require(
      !hasKey(VoxelVariantsRegistryTableId, VoxelVariantsRegistry.encodeKeyTuple(voxelVariantId)),
      "Voxel variant ID has already been registered"
    );

    bytes32[][] memory variants = getKeysInTable(VoxelVariantsRegistryTableId);
    uint256 voxelVariantIdCounter = variants.length;
    voxelVariant.variantId = voxelVariantIdCounter;
    VoxelVariantsRegistry.set(voxelVariantId, voxelVariant);
  }
}
