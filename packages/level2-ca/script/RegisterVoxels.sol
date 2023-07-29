// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { REGISTRY_ADDRESS, DirtVoxelID, DirtVoxelVariantID, DirtTexture, DirtUVWrap, GrassVoxelID, GrassVoxelVariantID, GrassTexture, GrassSideTexture, GrassUVWrap, BedrockVoxelID, BedrockVoxelVariantID, BedrockTexture, BedrockUVWrap, Level2AirVoxelID, SignalVoxelID, SignalOffVoxelVariantID, SignalOnVoxelVariantID, SignalOnTexture, SignalOffTexture, SignalOnUVWrap, SignalOffUVWrap } from "@composed-ca/src/Constants.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { AirVoxelVariantID, AirVoxelID, ElectronVoxelID } from "@tenet-base-ca/src/Constants.sol";

function registerAir() {
  bytes32[] memory airChildVoxelTypes = new bytes32[](8);
  for (uint i = 0; i < 8; i++) {
    airChildVoxelTypes[i] = AirVoxelID;
  }
  registerVoxelType(REGISTRY_ADDRESS, "Level 2 Air", Level2AirVoxelID, airChildVoxelTypes, AirVoxelVariantID);
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

  bytes32[] memory dirtChildVoxelTypes = new bytes32[](8);
  for (uint i = 0; i < 8; i++) {
    dirtChildVoxelTypes[i] = AirVoxelID;
  }
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

  bytes32[] memory grassChildVoxelTypes = new bytes32[](8);
  for (uint i = 0; i < 8; i++) {
    grassChildVoxelTypes[i] = AirVoxelID;
  }
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

  bytes32[] memory bedrockChildVoxelTypes = new bytes32[](8);
  for (uint i = 0; i < 8; i++) {
    bedrockChildVoxelTypes[i] = AirVoxelID;
  }
  registerVoxelType(REGISTRY_ADDRESS, "Bedrock", BedrockVoxelID, bedrockChildVoxelTypes, BedrockVoxelVariantID);
}

function registerSignal() {
  VoxelVariantsRegistryData memory signalOffVariant;
  signalOffVariant.blockType = NoaBlockType.BLOCK;
  signalOffVariant.opaque = true;
  signalOffVariant.solid = true;
  string[] memory signalOffMaterials = new string[](1);
  signalOffMaterials[0] = SignalOffTexture;
  signalOffVariant.materials = abi.encode(signalOffMaterials);
  signalOffVariant.uvWrap = SignalOffUVWrap;
  registerVoxelVariant(REGISTRY_ADDRESS, SignalOffVoxelVariantID, signalOffVariant);

  VoxelVariantsRegistryData memory signalOnVariant;
  signalOnVariant.blockType = NoaBlockType.BLOCK;
  signalOnVariant.opaque = true;
  signalOnVariant.solid = true;
  string[] memory signalOnMaterials = new string[](1);
  signalOnMaterials[0] = SignalOnTexture;
  signalOnVariant.materials = abi.encode(signalOnMaterials);
  signalOnVariant.uvWrap = SignalOnUVWrap;
  registerVoxelVariant(REGISTRY_ADDRESS, SignalOnVoxelVariantID, signalOnVariant);

  bytes32[] memory signalChildVoxelTypes = new bytes32[](8);
  signalChildVoxelTypes[4] = ElectronVoxelID;
  signalChildVoxelTypes[5] = ElectronVoxelID;
  registerVoxelType(REGISTRY_ADDRESS, "Signal", SignalVoxelID, signalChildVoxelTypes, SignalOffVoxelVariantID);
}
