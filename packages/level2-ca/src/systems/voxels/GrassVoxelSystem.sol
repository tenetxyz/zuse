// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig } from "@tenet-level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, GrassVoxelID, GrassVoxelVariantID, DirtTexture, GrassTexture, GrassSideTexture, GrassUVWrap } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

contract GrassVoxelSystem is System {
  function registerVoxelGrass() public {
    address world = _world();
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

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      GrassVoxelID,
      IWorld(world).enterWorldGrass.selector,
      IWorld(world).exitWorldGrass.selector,
      IWorld(world).variantSelectorGrass.selector
    );
  }

  function enterWorldGrass(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function exitWorldGrass(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function variantSelectorGrass(address callerAddress, bytes32 entity) public view returns (bytes32) {
    return GrassVoxelVariantID;
  }
}
