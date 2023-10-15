// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CobblestoneShinglesVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";

bytes32 constant CobblestoneShinglesVoxelVariantID = bytes32(keccak256("cobblestoneShingles"));
string constant CobblestoneShinglesTexture = "bafkreihy3pblhqaqquwttcykwlyey3umpou57rkvtncpdrjo7mlgna53g4";
string constant CobblestoneShinglesUVWrap = "bafkreifsrs64rckwnfkwcyqkzpdo3tpa2at7jhe6bw7jhevkxa7estkdnm";

contract CobblestoneShinglesVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cobblestoneshinglesVariant;
    cobblestoneshinglesVariant.blockType = NoaBlockType.BLOCK;
    cobblestoneshinglesVariant.opaque = true;
    cobblestoneshinglesVariant.solid = true;
    string[] memory cobblestoneshinglesMaterials = new string[](1);
    cobblestoneshinglesMaterials[0] = CobblestoneShinglesTexture;
    cobblestoneshinglesVariant.materials = abi.encode(cobblestoneshinglesMaterials);
    cobblestoneshinglesVariant.uvWrap = CobblestoneShinglesUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, CobblestoneShinglesVoxelVariantID, cobblestoneshinglesVariant);

    bytes32[] memory cobblestoneshinglesChildVoxelTypes = new bytes32[](1);
    cobblestoneshinglesChildVoxelTypes[0] = CobblestoneShinglesVoxelID;
    bytes32 baseVoxelTypeId = CobblestoneShinglesVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "CobblestoneShingles",
      CobblestoneShinglesVoxelID,
      baseVoxelTypeId,
      cobblestoneshinglesChildVoxelTypes,
      cobblestoneshinglesChildVoxelTypes,
      CobblestoneShinglesVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).ca_CobblestoneShing_enterWorld.selector,
        IWorld(world).ca_CobblestoneShing_exitWorld.selector,
        IWorld(world).ca_CobblestoneShing_variantSelector.selector,
        IWorld(world).ca_CobblestoneShing_activate.selector,
        IWorld(world).ca_CobblestoneShing_eventHandler.selector,
        IWorld(world).ca_CobblestoneShing_neighbourEventHandler.selector
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
    return CobblestoneShinglesVoxelVariantID;
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
