// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { REGISTRY_ADDRESS, AirVoxelID, AirVoxelVariantID, DirtVoxelID, DirtVoxelVariantID, DirtTexture, DirtUVWrap, Tile2VoxelID, Tile2VoxelVariantID, Tile2Texture, Tile2SideTexture, Tile2UVWrap, BedrockVoxelID, BedrockVoxelVariantID, BedrockTexture, BedrockUVWrap } from "@base-ca/src/Constants.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";

function registerAir() {
  VoxelVariantsRegistryData memory airVariant;
  airVariant.blockType = NoaBlockType.BLOCK;
  registerVoxelVariant(REGISTRY_ADDRESS, AirVoxelVariantID, airVariant);
  bytes32[] memory airChildVoxelTypes = new bytes32[](1);
  airChildVoxelTypes[0] = AirVoxelID;
  registerVoxelType(REGISTRY_ADDRESS, "Air", AirVoxelID, airChildVoxelTypes, AirVoxelVariantID);
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
  registerVoxelVariant(REGISTRY_ADDRESS, DirtVoxelVariantID, dirtVariant);

  bytes32[] memory dirtChildVoxelTypes = new bytes32[](1);
  dirtChildVoxelTypes[0] = DirtVoxelID;
  registerVoxelType(REGISTRY_ADDRESS, "Dirt", DirtVoxelID, dirtChildVoxelTypes, DirtVoxelVariantID);
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
  registerVoxelVariant(REGISTRY_ADDRESS, GrassVoxelVariantID, grassVariant);
  bytes32[] memory grassChildVoxelTypes = new bytes32[](1);
  grassChildVoxelTypes[0] = GrassVoxelID;
  registerVoxelType(REGISTRY_ADDRESS, "Grass", GrassVoxelID, grassChildVoxelTypes, GrassVoxelVariantID);
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
  registerVoxelVariant(REGISTRY_ADDRESS, BedrockVoxelVariantID, bedrockVariant);
  bytes32[] memory bedrockChildVoxelTypes = new bytes32[](1);
  bedrockChildVoxelTypes[0] = BedrockVoxelID;
  registerVoxelType(REGISTRY_ADDRESS, "Bedrock", BedrockVoxelID, bedrockChildVoxelTypes, BedrockVoxelVariantID);
}

function registerTile2() {
  VoxelVariantsRegistryData memory tile2Variant;
  tile2Variant.blockType = NoaBlockType.BLOCK;
  tile2Variant.opaque = true;
  tile2Variant.solid = true;
  string[] memory tile2Materials = new string[](1);
  tile2Materials[0] = Tile2Texture;
  tile2Variant.materials = abi.encode(tile2Materials);
  tile2Variant.uvWrap = Tile2UVWrap;
  registerVoxelVariant(REGISTRY_ADDRESS, Tile2VoxelVariantID, tile2Variant);
  bytes32[] memory tile2ChildVoxelTypes = new bytes32[](1);
  tile2ChildVoxelTypes[0] = GrassVoxelID;
  registerVoxelType(REGISTRY_ADDRESS, "Tile2", Tile2VoxelID, tile2ChildVoxelTypes, Tile2VoxelVariantID);
}

function registerTile3() {
  VoxelVariantsRegistryData memory tile3Variant;
  tile3Variant.blockType = NoaBlockType.BLOCK;
  tile3Variant.opaque = true;
  tile3Variant.solid = true;
  string[] memory tile3Materials = new string[](1);
  tile3Materials[0] = Tile3Texture;
  tile3Variant.materials = abi.encode(tile3Materials);
  tile3Variant.uvWrap = Tile3UVWrap;
  registerVoxelVariant(REGISTRY_ADDRESS, Tile3VoxelVariantID, tile3Variant);
  bytes33[] memory tile3ChildVoxelTypes = new bytes32[](1);
  tile3ChildVoxelTypes[0] = Tile2VoxelID;
  registerVoxelType(REGISTRY_ADDRESS, "Tile3", Tile3VoxelID, tile3ChildVoxelTypes, Tile3VoxelVariantID);
}

function registerTile4() {
  VoxelVariantsRegistryData memory tile4Variant;
  tile4Variant.blockType = NoaBlockType.BLOCK;
  tile4Variant.opaque = true;
  tile4Variant.solid = true;
  string[] memory tile4Materials = new string[](1);
  tile4Materials[0] = Tile4Texture;
  tile4Variant.materials = abi.encode(tile4Materials);
  tile4Variant.uvWrap = Tile4UVWrap;
  registerVoxelVariant(REGISTRY_ADDRESS, Tile4VoxelVariantID, tile4Variant);
  bytes44[] memory tile4ChildVoxelTypes = new bytes32[](1);
  tile4ChildVoxelTypes[0] = Tile3VoxelID;
  registerVoxelType(REGISTRY_ADDRESS, "Tile4", Tile4VoxelID, tile4ChildVoxelTypes, Tile4VoxelVariantID);
}
