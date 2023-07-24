// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "../../prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Occurrence, VoxelTypeData, VoxelVariantsData } from "@tenet-contracts/src/codegen/Tables.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { TENET_NAMESPACE } from "../../Constants.sol";

bytes32 constant Tile2ID = bytes32(keccak256("tile2"));

string constant Tile2Texture = "bafkreifun5pqgayquwuhorneu67bbz5q6mizqq323rxcszftlloatzavuq";

string constant Tile2UVWrap = "bafkreidp4ec6ntaqoxhc6fdjearell4hqynvgkrmpepmtvdrkikmt72kfe";

contract Tile2VoxelSystem is VoxelType {
  function registerVoxel() public override {
    IWorld world = IWorld(_world());

    VoxelVariantsData memory tile2Variant;
    tile2Variant.blockType = NoaBlockType.BLOCK;
    tile2Variant.opaque = true;
    tile2Variant.solid = true;
    string[] memory tile2Materials = new string[](1);
    tile2Materials[0] = Tile2Texture;
    tile2Variant.materials = abi.encode(tile2Materials);
    tile2Variant.uvWrap = Tile2UVWrap;
    world.tenet_VoxelRegistrySys_registerVoxelVariant(Tile2ID, tile2Variant);

    world.tenet_VoxelRegistrySys_registerVoxelType(
      "Tile2",
      Tile2ID,
      TENET_NAMESPACE,
      Tile2ID,
      world.tenet_Tile2VoxelSystem_variantSelector.selector,
      world.tenet_Tile2VoxelSystem_enterWorld.selector,
      world.tenet_Tile2VoxelSystem_exitWorld.selector,
      world.tenet_Tile2VoxelSystem_activate.selector
    );

    Occurrence.set(Tile2ID, world.tenet_OccurrenceSystem_OTile2.selector);
  }

  function enterWorld(bytes32 entity) public override {}

  function exitWorld(bytes32 entity) public override {}

  function variantSelector(bytes32 entity) public pure override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: Tile2ID });
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
