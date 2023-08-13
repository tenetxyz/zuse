// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, BedrockVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";

bytes32 constant BedrockVoxelVariantID = bytes32(keccak256("bedrock"));
string constant BedrockTexture = "bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a";
string constant BedrockUVWrap = "bafkreihdit6glam7sreijo7itbs7uwc2ltfeuvcfaublxf6rjo24hf6t4y";

contract BedrockVoxelSystem is VoxelType {
  function registerVoxel() public override {
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
    bytes32 baseVoxelTypeId = BedrockVoxelID;
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Bedrock",
      BedrockVoxelID,
      baseVoxelTypeId,
      bedrockChildVoxelTypes,
      bedrockChildVoxelTypes,
      BedrockVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).ca_BedrockVoxelSyst_enterWorld.selector,
        IWorld(world).ca_BedrockVoxelSyst_exitWorld.selector,
        IWorld(world).ca_BedrockVoxelSyst_variantSelector.selector,
        IWorld(world).ca_BedrockVoxelSyst_activate.selector,
        IWorld(world).ca_BedrockVoxelSyst_eventHandler.selector
      )
    );
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BedrockVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32, bytes32[] memory) {}
}
