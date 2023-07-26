// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { AirVoxelID, AirVoxelVariantID, DirtVoxelID, DirtVoxelVariantID, DirtTexture, DirtUVWrap, GrassVoxelID, GrassVoxelVariantID, GrassTexture, GrassSideTexture, GrassUVWrap, BedrockVoxelID, BedrockVoxelVariantID, BedrockTexture, BedrockUVWrap } from "@base-ca/src/Constants.sol";
import { registerVoxelVariant, registerVoxelType } from "@base-ca/src/Utils.sol";

function registerAir() {
  VoxelVariantsRegistryData memory airVariant;
  airVariant.blockType = NoaBlockType.BLOCK;
  registerVoxelVariant(AirVoxelVariantID, airVariant);
  bytes32[] memory airChildVoxelTypes = new bytes32[](1);
  airChildVoxelTypes[0] = AirVoxelID;
  registerVoxelType("Air", AirVoxelID, airChildVoxelTypes, AirVoxelVariantID);
}

function registerDirt() {
  VoxelVariantsRegistryData memory dirtVariant;
  dirtVariant.blockType = NoaBlockType.BLOCK;
  dirtVariant.opaque = true;
  dirtVariant.solid = true;
  string[] memory dirtMaterials = new string[](1);
  dirtMaterials[0] = DirtTexture;
  dirtVariant.materials = abi.encode(dirtMaterials);
  dirtVariant.uvWrap = DirtUVWrap;
  registerVoxelVariant(DirtVoxelVariantID, dirtVariant);

  bytes32[] memory dirtChildVoxelTypes = new bytes32[](1);
  dirtChildVoxelTypes[0] = DirtVoxelID;
  registerVoxelType("Dirt", DirtVoxelID, dirtChildVoxelTypes, DirtVoxelVariantID);
}

function registerGrass() {
  VoxelVariantsRegistryData memory grassVariant;
  grassVariant.blockType = NoaBlockType.BLOCK;
  grassVariant.opaque = true;
  grassVariant.solid = true;
  string[] memory grassMaterials = new string[](3);
  grassMaterials[0] = GrassTexture;
  grassMaterials[1] = DirtTexture;
  grassMaterials[2] = GrassSideTexture;
  grassVariant.materials = abi.encode(grassMaterials);
  grassVariant.uvWrap = GrassUVWrap;
  registerVoxelVariant(GrassVoxelVariantID, grassVariant);
  bytes32[] memory grassChildVoxelTypes = new bytes32[](1);
  grassChildVoxelTypes[0] = GrassVoxelID;
  registerVoxelType("Grass", GrassVoxelID, grassChildVoxelTypes, GrassVoxelVariantID);
}

function registerBedrock() {
  VoxelVariantsRegistryData memory bedrockVariant;
  bedrockVariant.blockType = NoaBlockType.BLOCK;
  bedrockVariant.opaque = true;
  bedrockVariant.solid = true;
  string[] memory bedrockMaterials = new string[](1);
  bedrockMaterials[0] = BedrockTexture;
  bedrockVariant.materials = abi.encode(bedrockMaterials);
  bedrockVariant.uvWrap = BedrockUVWrap;
  registerVoxelVariant(BedrockVoxelVariantID, bedrockVariant);
  bytes32[] memory bedrockChildVoxelTypes = new bytes32[](1);
  bedrockChildVoxelTypes[0] = BedrockVoxelID;
  registerVoxelType("Bedrock", BedrockVoxelID, bedrockChildVoxelTypes, BedrockVoxelVariantID);
}
