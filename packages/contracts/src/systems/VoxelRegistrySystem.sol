// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { NamespaceOwner } from "@latticexyz/world/src/tables/NamespaceOwner.sol";
import { FunctionSelectors } from "@latticexyz/world/src/modules/core/tables/FunctionSelectors.sol";
import { VoxelTypeRegistry, VoxelTypeRegistryData, VoxelTypeRegistryTableId, VoxelVariants, VoxelVariantsData, VoxelVariantsTableId } from "../codegen/Tables.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import { NoaBlockType } from "../codegen/Types.sol";
import { getCallerNamespace } from "../sharedutils.sol";

contract VoxelRegistrySystem is System {
  function registerVoxelType(
    string memory name,
    bytes32 voxelType,
    string memory previewVoxelImg,
    bytes4 voxelVariantSelector
  ) public {
    (bytes16 namespace, , ) = FunctionSelectors.get(voxelVariantSelector);
    require(NamespaceOwner.get(namespace) == _msgSender(), "Caller is not namespace owner");

    // check if voxel type is already registered
    bytes32[] memory keyTuple = new bytes32[](2);
    keyTuple[0] = bytes32((namespace));
    keyTuple[1] = voxelType;

    require(!hasKey(VoxelTypeRegistryTableId, keyTuple), "Voxel type already registered for this namespace");

    // TODO: We should add some signature check for voxelVariantSelector to make sure it returns the right type

    // register voxel type
    VoxelTypeRegistry.set(
      namespace,
      voxelType,
      VoxelTypeRegistryData({
        voxelVariantSelector: voxelVariantSelector,
        creator: _msgSender(),
        numSpawns: 0,
        name: name,
        preview: previewVoxelImg
      })
    );
  }

  function registerVoxelVariant(bytes32 voxelVariantId, VoxelVariantsData memory voxelVariant) public {
    // get caller's namespace
    bytes16 callerNamespace = getCallerNamespace(_msgSender());

    // check if voxel type is already registered
    bytes32[] memory keyTuple = new bytes32[](2);
    keyTuple[0] = bytes32((callerNamespace));
    keyTuple[1] = voxelVariantId;

    require(!hasKey(VoxelVariantsTableId, keyTuple), "Voxel variant already registered for this namespace");

    bytes32[][] memory variants = getKeysInTable(VoxelVariantsTableId);
    uint256 voxelVariantIdCounter = variants.length;
    voxelVariant.variantId = voxelVariantIdCounter;

    VoxelVariants.set(callerNamespace, voxelVariantId, voxelVariant);
  }
}
