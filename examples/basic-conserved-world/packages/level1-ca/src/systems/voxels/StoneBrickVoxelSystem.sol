// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, StoneBrickVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";

bytes32 constant StoneBrickVoxelVariantID = bytes32(keccak256("stoneBrick"));
string constant StoneBrickTexture = "bafkreihy3pblhqaqquwttcykwlyey3umpou57rkvtncpdrjo7mlgna53g4";
string constant StoneBrickUVWrap = "bafkreifsrs64rckwnfkwcyqkzpdo3tpa2at7jhe6bw7jhevkxa7estkdnm";

contract StoneBrickVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory stonebrickVariant;
    stonebrickVariant.blockType = NoaBlockType.BLOCK;
    stonebrickVariant.opaque = true;
    stonebrickVariant.solid = true;
    string[] memory stonebrickMaterials = new string[](1);
    stonebrickMaterials[0] = StoneBrickTexture;
    stonebrickVariant.materials = abi.encode(stonebrickMaterials);
    stonebrickVariant.uvWrap = StoneBrickUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, StoneBrickVoxelVariantID, stonebrickVariant);

    bytes32[] memory stonebrickChildVoxelTypes = new bytes32[](1);
    stonebrickChildVoxelTypes[0] = StoneBrickVoxelID;
    bytes32 baseVoxelTypeId = StoneBrickVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "StoneBrick",
      StoneBrickVoxelID,
      baseVoxelTypeId,
      stonebrickChildVoxelTypes,
      stonebrickChildVoxelTypes,
      StoneBrickVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).ca_StoneBrickVoxelSystem_enterWorld.selector,
        IWorld(world).ca_StoneBrickVoxelSystem_exitWorld.selector,
        IWorld(world).ca_StoneBrickVoxelSystem_variantSelector.selector,
        IWorld(world).ca_StoneBrickVoxelSystem_activate.selector,
        IWorld(world).ca_StoneBrickVoxelSystem_eventHandler.selector,
        IWorld(world).ca_StoneBrickVoxelSystem_neighbourEventHandler.selector
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
    return StoneBrickVoxelVariantID;
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
