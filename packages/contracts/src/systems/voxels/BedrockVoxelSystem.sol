// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelType } from "@tenet-contracts/src/prototypes/VoxelType.sol";
import { IWorld } from "../../../src/codegen/world/IWorld.sol";
import { Occurrence } from "@tenet-contracts/src/codegen/Tables.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { REGISTER_VOXEL_TYPE_SIG, REGISTER_VOXEL_VARIANT_SIG } from "@tenet-registry/src/Constants.sol";
import { REGISTRY_WORLD } from "../../Constants.sol";

bytes32 constant BedrockID = bytes32(keccak256("bedrock"));

string constant BedrockTexture = "bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a";

string constant BedrockUVWrap = "bafkreihdit6glam7sreijo7itbs7uwc2ltfeuvcfaublxf6rjo24hf6t4y";

contract BedrockVoxelSystem is VoxelType {
  function registerVoxel() public override {
    IWorld world = IWorld(_world());

    VoxelVariantsRegistryData memory bedrockVariant;
    bedrockVariant.blockType = NoaBlockType.BLOCK;
    bedrockVariant.opaque = true;
    bedrockVariant.solid = true;
    string[] memory bedrockMaterials = new string[](1);
    bedrockMaterials[0] = BedrockTexture;
    bedrockVariant.materials = abi.encode(bedrockMaterials);
    bedrockVariant.uvWrap = BedrockUVWrap;

    REGISTRY_WORLD.call(abi.encodeWithSignature(REGISTER_VOXEL_VARIANT_SIG, BedrockID, bedrockVariant));
    REGISTRY_WORLD.call(abi.encodeWithSignature(REGISTER_VOXEL_TYPE_SIG, "Bedrock", BedrockID, BedrockID, _world()));

    Occurrence.set(BedrockID, world.tenet_OccurrenceSystem_OBedrock.selector);
  }

  function enterWorld(bytes32 entity) public override {}

  function exitWorld(bytes32 entity) public override {}

  function variantSelector(bytes32 entity) public pure override returns (bytes32) {
    return BedrockID;
  }

  function activate(bytes32 entity) public override returns (bytes memory) {}
}
