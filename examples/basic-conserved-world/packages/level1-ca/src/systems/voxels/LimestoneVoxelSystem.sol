// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, LimestoneVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";

bytes32 constant LimestoneVoxelVariantID = bytes32(keccak256("limestone"));
string constant LimestoneTexture = "bafkreihy3pblhqaqquwttcykwlyey3umpou57rkvtncpdrjo7mlgna53g4";
string constant LimestoneUVWrap = "bafkreifsrs64rckwnfkwcyqkzpdo3tpa2at7jhe6bw7jhevkxa7estkdnm";

contract LimestoneVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory limestoneVariant;
    limestoneVariant.blockType = NoaBlockType.BLOCK;
    limestoneVariant.opaque = true;
    limestoneVariant.solid = true;
    string[] memory limestoneMaterials = new string[](1);
    limestoneMaterials[0] = LimestoneTexture;
    limestoneVariant.materials = abi.encode(limestoneMaterials);
    limestoneVariant.uvWrap = LimestoneUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, LimestoneVoxelVariantID, limestoneVariant);

    bytes32[] memory limestoneChildVoxelTypes = new bytes32[](1);
    limestoneChildVoxelTypes[0] = LimestoneVoxelID;
    bytes32 baseVoxelTypeId = LimestoneVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Limestone",
      LimestoneVoxelID,
      baseVoxelTypeId,
      limestoneChildVoxelTypes,
      limestoneChildVoxelTypes,
      LimestoneVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).ca_LimestoneVoxelSystem_enterWorld.selector,
        IWorld(world).ca_LimestoneVoxelSystem_exitWorld.selector,
        IWorld(world).ca_LimestoneVoxelSystem_variantSelector.selector,
        IWorld(world).ca_LimestoneVoxelSystem_activate.selector,
        IWorld(world).ca_LimestoneVoxelSystem_eventHandler.selector,
        IWorld(world).ca_LimestoneVoxelSystem_neighbourEventHandler.selector
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
    return LimestoneVoxelVariantID;
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
