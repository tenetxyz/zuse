// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenet-contracts/src/prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Occurrence, VoxelTypeData, VoxelVariantsData } from "@tenet-contracts/src/codegen/Tables.sol";
import { NoaBlockType } from "@tenet-contracts/src/codegen/Types.sol";
import { VoxelVariantsKey } from "@tenet-contracts/src/Types.sol";
import { TENET_NAMESPACE } from "../../Constants.sol";

bytes32 constant BedrockID = bytes32(keccak256("bedrock"));

string constant BedrockTexture = "bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a";

string constant BedrockUVWrap = "bafkreihdit6glam7sreijo7itbs7uwc2ltfeuvcfaublxf6rjo24hf6t4y";

contract BedrockVoxelSystem is VoxelType {
  function registerVoxel() public override {
    IWorld world = IWorld(_world());

    VoxelVariantsData memory bedrockVariant;
    bedrockVariant.blockType = NoaBlockType.BLOCK;
    bedrockVariant.opaque = true;
    bedrockVariant.solid = true;
    string[] memory bedrockMaterials = new string[](1);
    bedrockMaterials[0] = BedrockTexture;
    bedrockVariant.materials = abi.encode(bedrockMaterials);
    bedrockVariant.uvWrap = BedrockUVWrap;

    world.tenet_VoxelRegistrySys_registerVoxelVariant(BedrockID, bedrockVariant);

    world.tenet_VoxelRegistrySys_registerVoxelType(
      "Bedrock",
      BedrockID,
      TENET_NAMESPACE,
      BedrockID,
      world.tenet_BedrockVoxelSyst_variantSelector.selector,
      world.tenet_BedrockVoxelSyst_enterWorld.selector,
      world.tenet_BedrockVoxelSyst_exitWorld.selector,
      world.tenet_BedrockVoxelSyst_activate.selector
    );

    Occurrence.set(BedrockID, world.tenet_OccurrenceSystem_OBedrock.selector);
  }

  function enterWorld(bytes32 entity) public override {}

  function exitWorld(bytes32 entity) public override {}

  function variantSelector(bytes32 entity) public pure override returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: BedrockID });
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
