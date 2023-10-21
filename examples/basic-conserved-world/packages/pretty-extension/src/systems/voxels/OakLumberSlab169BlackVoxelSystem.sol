// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberSlab169BlackVoxelID = bytes32(keccak256("oak_lumber_slab_169_black"));
bytes32 constant OakLumberSlab169BlackVoxelVariantID = bytes32(keccak256("oak_lumber_slab_169_black"));

contract OakLumberSlab169BlackVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberSlab169BlackVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberSlab169BlackVoxelVariantID, oakLumberSlab169BlackVariant);

    bytes32[] memory oakLumberSlab169BlackChildVoxelTypes = new bytes32[](1);
    oakLumberSlab169BlackChildVoxelTypes[0] = OakLumberSlab169BlackVoxelID;
    bytes32 baseVoxelTypeId = OakLumberSlab169BlackVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Slab169 Black",
      OakLumberSlab169BlackVoxelID,
      baseVoxelTypeId,
      oakLumberSlab169BlackChildVoxelTypes,
      oakLumberSlab169BlackChildVoxelTypes,
      OakLumberSlab169BlackVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C311699_enterWorld.selector,
        IWorld(world).pretty_C311699_exitWorld.selector,
        IWorld(world).pretty_C311699_variantSelector.selector,
        IWorld(world).pretty_C311699_activate.selector,
        IWorld(world).pretty_C311699_eventHandler.selector,
        IWorld(world).pretty_C311699_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberSlab169BlackVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberSlab169BlackVoxelVariantID;
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
