// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, OrangeFlowerVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

bytes32 constant OrangeFlowerVoxelVariantID = bytes32(keccak256("orangeflower"));

string constant OrangeFlowerTexture = "bafkreicins36cmwliwf7ryrlcs32khvi6kleof6buiirlvgv2w6cejpg54";

contract FlowerVoxelSystem is System {
  function registerVoxelFlower() public {
    address world = _world();
    VoxelVariantsRegistryData memory orangeFlowerVariant;
    orangeFlowerVariant.blockType = NoaBlockType.MESH;
    orangeFlowerVariant.opaque = false;
    orangeFlowerVariant.solid = false;
    orangeFlowerVariant.frames = 1;
    string[] memory orangeFlowerMaterials = new string[](1);
    orangeFlowerMaterials[0] = OrangeFlowerTexture;
    orangeFlowerVariant.materials = abi.encode(orangeFlowerMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, OrangeFlowerVoxelVariantID, orangeFlowerVariant);

    bytes32[] memory flowerChildVoxelTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      flowerChildVoxelTypes[i] = AirVoxelID;
    }
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Orange Flower",
      OrangeFlowerVoxelID,
      flowerChildVoxelTypes,
      OrangeFlowerVoxelVariantID
    );

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      OrangeFlowerVoxelID,
      IWorld(world).enterWorldFlower.selector,
      IWorld(world).exitWorldFlower.selector,
      IWorld(world).variantSelectorFlower.selector
    );
  }

  function enterWorldFlower(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function exitWorldFlower(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function variantSelectorFlower(
    address callerAddress,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view returns (bytes32) {
    return OrangeFlowerVoxelVariantID;
  }
}
