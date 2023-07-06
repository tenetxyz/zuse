// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Occurrence, VoxelTypeData, VoxelVariantsData } from "../../codegen/Tables.sol";
import { NoaBlockType } from "../../codegen/Types.sol";
import { VoxelVariantsKey } from "../../Types.sol";
import { TENET_NAMESPACE } from "../../Constants.sol";

bytes32 constant BedrockID = bytes32(keccak256("bedrock"));

string constant BedrockTexture = "bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a";

string constant BedrockUVWrap = "bafkreihdit6glam7sreijo7itbs7uwc2ltfeuvcfaublxf6rjo24hf6t4y";

contract BedrockSystem is System {
  function registerBedrockVoxel() public {
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
      BedrockTexture,
      world.tenet_BedrockSystem_bedrockVariantSelector.selector
    );

    Occurrence.set(BedrockID, world.tenet_OccurrenceSystem_OBedrock.selector);
  }

  function bedrockVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
    return VoxelVariantsKey({ voxelVariantNamespace: TENET_NAMESPACE, voxelVariantId: BedrockID });
  }
}
