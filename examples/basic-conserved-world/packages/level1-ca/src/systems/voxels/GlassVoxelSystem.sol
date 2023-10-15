// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, GlassVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";

bytes32 constant GlassVoxelVariantID = bytes32(keccak256("glass"));
string constant GlassTexture = "bafkreihy3pblhqaqquwttcykwlyey3umpou57rkvtncpdrjo7mlgna53g4";
string constant GlassUVWrap = "bafkreifsrs64rckwnfkwcyqkzpdo3tpa2at7jhe6bw7jhevkxa7estkdnm";

contract GlassVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory glassVariant;
    glassVariant.blockType = NoaBlockType.BLOCK;
    glassVariant.opaque = true;
    glassVariant.solid = true;
    string[] memory glassMaterials = new string[](1);
    glassMaterials[0] = GlassTexture;
    glassVariant.materials = abi.encode(glassMaterials);
    glassVariant.uvWrap = GlassUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, GlassVoxelVariantID, glassVariant);

    bytes32[] memory glassChildVoxelTypes = new bytes32[](1);
    glassChildVoxelTypes[0] = GlassVoxelID;
    bytes32 baseVoxelTypeId = GlassVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Glass",
      GlassVoxelID,
      baseVoxelTypeId,
      glassChildVoxelTypes,
      glassChildVoxelTypes,
      GlassVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).ca_GlassVoxelSystem_enterWorld.selector,
        IWorld(world).ca_GlassVoxelSystem_exitWorld.selector,
        IWorld(world).ca_GlassVoxelSystem_variantSelector.selector,
        IWorld(world).ca_GlassVoxelSystem_activate.selector,
        IWorld(world).ca_GlassVoxelSystem_eventHandler.selector,
        IWorld(world).ca_GlassVoxelSystem_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
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
    return GlassVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bool, bytes memory) {}

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public override returns (bool, bytes memory) {}
}
