// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, LightVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";

bytes32 constant LightVoxelVariantID = bytes32(keccak256("light"));
string constant LightTexture = "bafkreihy3pblhqaqquwttcykwlyey3umpou57rkvtncpdrjo7mlgna53g4";
string constant LightUVWrap = "bafkreifsrs64rckwnfkwcyqkzpdo3tpa2at7jhe6bw7jhevkxa7estkdnm";

contract LightVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory lightVariant;
    lightVariant.blockType = NoaBlockType.BLOCK;
    lightVariant.opaque = true;
    lightVariant.solid = true;
    string[] memory lightMaterials = new string[](1);
    lightMaterials[0] = LightTexture;
    lightVariant.materials = abi.encode(lightMaterials);
    lightVariant.uvWrap = LightUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, LightVoxelVariantID, lightVariant);

    bytes32[] memory lightChildVoxelTypes = new bytes32[](1);
    lightChildVoxelTypes[0] = LightVoxelID;
    bytes32 baseVoxelTypeId = LightVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Light",
      LightVoxelID,
      baseVoxelTypeId,
      lightChildVoxelTypes,
      lightChildVoxelTypes,
      LightVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).ca_LightVoxelSystem_enterWorld.selector,
        IWorld(world).ca_LightVoxelSystem_exitWorld.selector,
        IWorld(world).ca_LightVoxelSystem_variantSelector.selector,
        IWorld(world).ca_LightVoxelSystem_activate.selector,
        IWorld(world).ca_LightVoxelSystem_eventHandler.selector,
        IWorld(world).ca_LightVoxelSystem_neighbourEventHandler.selector
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
    return LightVoxelVariantID;
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
