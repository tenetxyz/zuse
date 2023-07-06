// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";

import { IWorld } from "../../../src/codegen/world/IWorld.sol";

import { registerVoxelType, registerVoxelVariant } from "../../Utils.sol";
import { VoxelVariantsData, VoxelVariantsKey } from "../../Types.sol";
import { EXTENSION_NAMESPACE } from "../../Constants.sol";
import { NoaBlockType } from "@tenetxyz/contracts/src/codegen/types.sol";

bytes32 constant OrangeFlowerID = bytes32(keccak256("orangeflower"));

string constant OrangeFlowerTexture = "bafkreicins36cmwliwf7ryrlcs32khvi6kleof6buiirlvgv2w6cejpg54";

contract FlowerSystem is System {
  function registerFlowerVoxels() public {
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
      OrangeFlowerTexture,
      IWorld(world).extension_FlowerSystem_orangeFlowerVariantSelector.selector
    );
  }

  function orangeFlowerVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: EXTENSION_NAMESPACE, voxelVariantId: OrangeFlowerID });
  }
}
