// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "../../prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Occurrence, VoxelTypeData, VoxelVariantsData } from "@tenet-contracts/src/codegen/Tables.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { TENET_NAMESPACE } from "../../Constants.sol";

bytes32 constant TileID = bytes32(keccak256("tile"));

string constant TileTexture = "bafkreifw7lb4m42jw4wtkjy3zgwfr44uqkwg7uranqazei5knpkzbkexqa";

string constant TileUVWrap = "bafkreia52odexmenv7pcj7sm54nuu3ifylaijdckdkv7k3yxph4b6khnii";

contract TileVoxelSystem is VoxelType {
  function registerVoxel() public override {
    IWorld world = IWorld(_world());

    VoxelVariantsData memory tileVariant;
    tileVariant.blockType = NoaBlockType.BLOCK;
    tileVariant.opaque = true;
    tileVariant.solid = true;
    string[] memory tileMaterials = new string[](1);
    tileMaterials[0] = TileTexture;
    tileVariant.materials = abi.encode(tileMaterials);
    tileVariant.uvWrap = TileUVWrap;
    world.tenet_VoxelRegistrySys_registerVoxelVariant(TileID, tileVariant);

    world.tenet_VoxelRegistrySys_registerVoxelType(
      "Tile",
      TileID,
      TENET_NAMESPACE,
      TileID,
      world.tenet_TileVoxelSystem_variantSelector.selector,
      world.tenet_TileVoxelSystem_enterWorld.selector,
      world.tenet_TileVoxelSystem_exitWorld.selector,
      world.tenet_TileVoxelSystem_activate.selector
    );

    Occurrence.set(TileID, world.tenet_OccurrenceSystem_OTile.selector);
  }

  function enterWorld(bytes32 entity) public override {}

  function exitWorld(bytes32 entity) public override {}

  function variantSelector(bytes32 entity) public pure override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: TileID });
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
