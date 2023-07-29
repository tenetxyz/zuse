// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { REGISTRY_ADDRESS, AirVoxelID, AirVoxelVariantID, ElectronVoxelID, ElectronVoxelVariantID, ElectronTexture } from "@base-ca/src/Constants.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";

function registerAir() {
  VoxelVariantsRegistryData memory airVariant;
  airVariant.blockType = NoaBlockType.BLOCK;
  registerVoxelVariant(REGISTRY_ADDRESS, AirVoxelVariantID, airVariant);
  bytes32[] memory airChildVoxelTypes = new bytes32[](1);
  airChildVoxelTypes[0] = AirVoxelID;
  registerVoxelType(REGISTRY_ADDRESS, "Air", AirVoxelID, airChildVoxelTypes, AirVoxelVariantID);
}

function registerElectron() {
  VoxelVariantsRegistryData memory electronVariant;
  electronVariant.blockType = NoaBlockType.MESH;
  electronVariant.opaque = false;
  electronVariant.solid = false;
  electronVariant.frames = 1;
  string[] memory electronMaterials = new string[](1);
  electronMaterials[0] = ElectronTexture;
  electronVariant.materials = abi.encode(electronMaterials);
  registerVoxelVariant(REGISTRY_ADDRESS, ElectronVoxelVariantID, electronVariant);

  bytes32[] memory electronChildVoxelTypes = new bytes32[](1);
  electronChildVoxelTypes[0] = ElectronVoxelID;
  registerVoxelType(REGISTRY_ADDRESS, "Electron", ElectronVoxelID, electronChildVoxelTypes, ElectronVoxelVariantID);
}
