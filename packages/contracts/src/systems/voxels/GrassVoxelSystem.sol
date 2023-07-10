// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "../../prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Occurrence, VoxelTypeData, VoxelVariantsData } from "@tenet-contracts/src/codegen/Tables.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { TENET_NAMESPACE } from "../../Constants.sol";
import { DirtTexture } from "./DirtVoxelSystem.sol";

bytes32 constant GrassID = bytes32(keccak256("grass"));

string constant GrassTexture = "bafkreifmvm3yxzbkzcb2r7m6gavjhe22n4p3o36lz2ypkgf5v6i6zzhv4a";
string constant GrassSideTexture = "bafkreibp5wefex2cunqz5ffwt3ucw776qthwl6y6pswr2j2zuzldrv6bqa";

string constant GrassUVWrap = "bafkreihaagdyqnbie3eyx6upmoul2zb4qakubxg6bcha6k5ebp4fbsd3am";

contract GrassVoxelSystem is VoxelType {
  function registerVoxel() public override {
    IWorld world = IWorld(_world());

    VoxelVariantsData memory grassVariant;
    grassVariant.blockType = NoaBlockType.BLOCK;
    grassVariant.opaque = true;
    grassVariant.solid = true;
    string[] memory grassMaterials = new string[](3);
    grassMaterials[0] = GrassTexture;
    grassMaterials[1] = DirtTexture;
    grassMaterials[2] = GrassSideTexture;
    grassVariant.materials = abi.encode(grassMaterials);
    grassVariant.uvWrap = GrassUVWrap;

    world.tenet_VoxelRegistrySys_registerVoxelVariant(GrassID, grassVariant);

    world.tenet_VoxelRegistrySys_registerVoxelType(
      "Grass",
      GrassID,
      TENET_NAMESPACE,
      GrassID,
      world.tenet_GrassVoxelSystem_variantSelector.selector,
      world.tenet_GrassVoxelSystem_enterWorld.selector,
      world.tenet_GrassVoxelSystem_exitWorld.selector,
      world.tenet_GrassVoxelSystem_activate.selector
    );

    Occurrence.set(GrassID, world.tenet_OccurrenceSystem_OGrass.selector);
  }

  function enterWorld(bytes32 entity) public override {}

  function exitWorld(bytes32 entity) public override {}

  function variantSelector(bytes32 entity) public pure override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: GrassID });
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
