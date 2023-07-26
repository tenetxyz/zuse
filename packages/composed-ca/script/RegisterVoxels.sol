// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { REGISTRY_WORLD, RoadVoxelID, RoadVoxelVariantID, RoadTexture, RoadUVWrap, Level2AirVoxelID } from "@composed-ca/src/Constants.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { DirtVoxelID, AirVoxelVariantID, AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

function registerAir() {
  bytes32[] memory airChildVoxelTypes = new bytes32[](8);
  for (uint i = 0; i < 8; i++) {
    airChildVoxelTypes[i] = AirVoxelID;
  }
  registerVoxelType(REGISTRY_WORLD, "Level 2 Air", Level2AirVoxelID, airChildVoxelTypes, AirVoxelVariantID);
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
  registerVoxelVariant(REGISTRY_WORLD, RoadVoxelVariantID, roadVariant);

  bytes32[] memory roadChildVoxelTypes = new bytes32[](8);
  for (uint i = 0; i < 8; i++) {
    roadChildVoxelTypes[i] = DirtVoxelID;
  }
  registerVoxelType(REGISTRY_WORLD, "Road", RoadVoxelID, roadChildVoxelTypes, RoadVoxelVariantID);
}
