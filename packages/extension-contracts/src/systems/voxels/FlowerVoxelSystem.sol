// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenetxyz/contracts/src/prototypes/VoxelType.sol";
import { VoxelVariantsKey } from "@tenetxyz/contracts/src/Types.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { registerVoxelType, registerVoxelVariant } from "../../Utils.sol";
import { VoxelVariantsData } from "../../Types.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenetxyz/contracts/src/codegen/types.sol";

bytes32 constant OrangeFlowerID = bytes32(keccak256("orangeflower"));

string constant OrangeFlowerTexture = "bafkreicins36cmwliwf7ryrlcs32khvi6kleof6buiirlvgv2w6cejpg54";

contract FlowerVoxelSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();

    VoxelVariantsData memory orangeFlowerVariant;
    orangeFlowerVariant.blockType = NoaBlockType.MESH;
    orangeFlowerVariant.opaque = false;
    orangeFlowerVariant.solid = false;
    orangeFlowerVariant.frames = 1;
    string[] memory orangeFlowerMaterials = new string[](1);
    orangeFlowerMaterials[0] = OrangeFlowerTexture;
    orangeFlowerVariant.materials = abi.encode(orangeFlowerMaterials);

    registerVoxelVariant(world, OrangeFlowerID, orangeFlowerVariant);

    registerVoxelType(
      world,
      "Orange Flower",
      OrangeFlowerID,
      EXTENSION_NAMESPACE,
      OrangeFlowerID,
      IWorld(world).extension_FlowerVoxelSyste_variantSelector.selector,
      IWorld(world).extension_FlowerVoxelSyste_enterWorld.selector,
      IWorld(world).extension_FlowerVoxelSyste_exitWorld.selector
    );
  }

  function enterWorld(bytes32 entity) public override {}

  function exitWorld(bytes32 entity) public override {}

  function variantSelector(bytes32 entity) public view override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: OrangeFlowerID });
  }
}
