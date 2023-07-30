// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { REGISTRY_ADDRESS, RoadVoxelID, RoadVoxelVariantID, RoadTexture, RoadUVWrap, Level3AirVoxelID } from "@tenet-level3-ca/src/Constants.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { AirVoxelVariantID } from "@tenet-base-ca/src/Constants.sol";
import { Level2AirVoxelID, DirtVoxelID } from "@tenet-level2-ca/src/Constants.sol";

function registerAir() {
  bytes32[] memory airChildVoxelTypes = new bytes32[](8);
  for (uint i = 0; i < 8; i++) {
    airChildVoxelTypes[i] = Level2AirVoxelID;
  }
  registerVoxelType(REGISTRY_ADDRESS, "Level 3 Air", Level3AirVoxelID, airChildVoxelTypes, AirVoxelVariantID);
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
