// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@level2-ca/src/codegen/world/IWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CAVoxelConfig } from "@level2-ca/src/codegen/Tables.sol";
import { REGISTRY_ADDRESS, BedrockVoxelID, BedrockVoxelVariantID, BedrockTexture, BedrockUVWrap } from "@level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

contract BedrockVoxelSystem is System {
  function registerVoxelBedrock() public {
    address world = _world();
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

    // TODO: Check to make sure it doesn't already exist
    CAVoxelConfig.set(
      BedrockVoxelID,
      IWorld(world).enterWorldBedrock.selector,
      IWorld(world).exitWorldBecrock.selector,
      IWorld(world).variantSelectorBedrock.selector
    );
  }

  function enterWorldBedrock(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function exitWorldBecrock(address callerAddress, VoxelCoord memory coord, bytes32 entity) public {}

  function variantSelectorBedrock(bytes32 entity) public view returns (bytes32) {
    return BedrockVoxelVariantID;
  }
}
