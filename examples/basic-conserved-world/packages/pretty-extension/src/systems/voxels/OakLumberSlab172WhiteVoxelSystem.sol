// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberSlab172WhiteVoxelID = bytes32(keccak256("oak_lumber_slab_172_white"));
bytes32 constant OakLumberSlab172WhiteVoxelVariantID = bytes32(keccak256("oak_lumber_slab_172_white"));

contract OakLumberSlab172WhiteVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberSlab172WhiteVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberSlab172WhiteVoxelVariantID, oakLumberSlab172WhiteVariant);

    bytes32[] memory oakLumberSlab172WhiteChildVoxelTypes = new bytes32[](1);
    oakLumberSlab172WhiteChildVoxelTypes[0] = OakLumberSlab172WhiteVoxelID;
    bytes32 baseVoxelTypeId = OakLumberSlab172WhiteVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Slab172 White",
      OakLumberSlab172WhiteVoxelID,
      baseVoxelTypeId,
      oakLumberSlab172WhiteChildVoxelTypes,
      oakLumberSlab172WhiteChildVoxelTypes,
      OakLumberSlab172WhiteVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D172E5_enterWorld.selector,
        IWorld(world).pretty_C31D172E5_exitWorld.selector,
        IWorld(world).pretty_C31D172E5_variantSelector.selector,
        IWorld(world).pretty_C31D172E5_activate.selector,
        IWorld(world).pretty_C31D172E5_eventHandler.selector,
        IWorld(world).pretty_C31D172E5_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberSlab172WhiteVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberSlab172WhiteVoxelVariantID;
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
