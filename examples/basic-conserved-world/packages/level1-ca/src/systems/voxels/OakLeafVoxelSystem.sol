// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, OakLeafVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";

bytes32 constant OakLeafVoxelVariantID = bytes32(keccak256("oakLeaf"));
string constant OakLeafTexture = "bafkreihy3pblhqaqquwttcykwlyey3umpou57rkvtncpdrjo7mlgna53g4";
string constant OakLeafUVWrap = "bafkreifsrs64rckwnfkwcyqkzpdo3tpa2at7jhe6bw7jhevkxa7estkdnm";

contract OakLeafVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakleafVariant;
    oakleafVariant.blockType = NoaBlockType.BLOCK;
    oakleafVariant.opaque = true;
    oakleafVariant.solid = true;
    string[] memory oakleafMaterials = new string[](1);
    oakleafMaterials[0] = OakLeafTexture;
    oakleafVariant.materials = abi.encode(oakleafMaterials);
    oakleafVariant.uvWrap = OakLeafUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLeafVoxelVariantID, oakleafVariant);

    bytes32[] memory oakleafChildVoxelTypes = new bytes32[](1);
    oakleafChildVoxelTypes[0] = OakLeafVoxelID;
    bytes32 baseVoxelTypeId = OakLeafVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "OakLeaf",
      OakLeafVoxelID,
      baseVoxelTypeId,
      oakleafChildVoxelTypes,
      oakleafChildVoxelTypes,
      OakLeafVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).ca_OakLeafVoxelSyst_enterWorld.selector,
        IWorld(world).ca_OakLeafVoxelSyst_exitWorld.selector,
        IWorld(world).ca_OakLeafVoxelSyst_variantSelector.selector,
        IWorld(world).ca_OakLeafVoxelSyst_activate.selector,
        IWorld(world).ca_OakLeafVoxelSyst_eventHandler.selector,
        IWorld(world).ca_OakLeafVoxelSyst_neighbourEventHandler.selector
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
    return OakLeafVoxelVariantID;
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
