// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { REGISTRY_ADDRESS, RoadVoxelID, RoadVoxelVariantID, RoadTexture, RoadUVWrap, Level2AirVoxelID, SignalVoxelID, SignalOffVoxelVariantID, SignalOnVoxelVariantID, SignalOnTexture, SignalOffTexture, SignalOnUVWrap, SignalOffUVWrap } from "@composed-ca/src/Constants.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { DirtVoxelID, AirVoxelVariantID, AirVoxelID, BedrockVoxelID } from "@tenet-base-ca/src/Constants.sol";

function registerAir() {
  bytes32[] memory airChildVoxelTypes = new bytes32[](8);
  for (uint i = 0; i < 8; i++) {
    airChildVoxelTypes[i] = AirVoxelID;
  }
  registerVoxelType(REGISTRY_ADDRESS, "Level 2 Air", Level2AirVoxelID, airChildVoxelTypes, AirVoxelVariantID);
}

function registerRoad() {
  VoxelVariantsRegistryData memory roadVariant;
  roadVariant.blockType = NoaBlockType.BLOCK;
  roadVariant.opaque = true;
  roadVariant.solid = true;
  string[] memory roadMaterials = new string[](1);
  roadMaterials[0] = RoadTexture;
  roadVariant.materials = abi.encode(roadMaterials);
  roadVariant.uvWrap = RoadUVWrap;
  registerVoxelVariant(REGISTRY_ADDRESS, RoadVoxelVariantID, roadVariant);

  bytes32[] memory roadChildVoxelTypes = new bytes32[](8);
  for (uint i = 0; i < 8; i++) {
    roadChildVoxelTypes[i] = DirtVoxelID;
  }
  registerVoxelType(REGISTRY_ADDRESS, "Road", RoadVoxelID, roadChildVoxelTypes, RoadVoxelVariantID);
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
  signalChildVoxelTypes[4] = BedrockVoxelID;
  signalChildVoxelTypes[5] = BedrockVoxelID;
  registerVoxelType(REGISTRY_ADDRESS, "Signal", SignalVoxelID, signalChildVoxelTypes, SignalOffVoxelVariantID);
}
