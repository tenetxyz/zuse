// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant GrassSlab133VoxelID = bytes32(keccak256("grass_slab_133"));
bytes32 constant GrassSlab133VoxelVariantID = bytes32(keccak256("grass_slab_133"));

contract GrassSlab133VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory grassSlab133Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, GrassSlab133VoxelVariantID, grassSlab133Variant);

    bytes32[] memory grassSlab133ChildVoxelTypes = new bytes32[](1);
    grassSlab133ChildVoxelTypes[0] = GrassSlab133VoxelID;
    bytes32 baseVoxelTypeId = GrassSlab133VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Grass Slab133",
      GrassSlab133VoxelID,
      baseVoxelTypeId,
      grassSlab133ChildVoxelTypes,
      grassSlab133ChildVoxelTypes,
      GrassSlab133VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C1D133_enterWorld.selector,
        IWorld(world).pretty_C1D133_exitWorld.selector,
        IWorld(world).pretty_C1D133_variantSelector.selector,
        IWorld(world).pretty_C1D133_activate.selector,
        IWorld(world).pretty_C1D133_eventHandler.selector,
        IWorld(world).pretty_C1D133_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, GrassSlab133VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return GrassSlab133VoxelVariantID;
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
