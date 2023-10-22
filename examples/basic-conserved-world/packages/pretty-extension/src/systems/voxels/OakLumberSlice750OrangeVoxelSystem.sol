// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberSlice750OrangeVoxelID = bytes32(keccak256("oak_lumber_slice_750_orange"));
bytes32 constant OakLumberSlice750OrangeVoxelVariantID = bytes32(keccak256("oak_lumber_slice_750_orange"));

contract OakLumberSlice750OrangeVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberSlice750OrangeVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberSlice750OrangeVoxelVariantID, oakLumberSlice750OrangeVariant);

    bytes32[] memory oakLumberSlice750OrangeChildVoxelTypes = new bytes32[](1);
    oakLumberSlice750OrangeChildVoxelTypes[0] = OakLumberSlice750OrangeVoxelID;
    bytes32 baseVoxelTypeId = OakLumberSlice750OrangeVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Slice750 Orange",
      OakLumberSlice750OrangeVoxelID,
      baseVoxelTypeId,
      oakLumberSlice750OrangeChildVoxelTypes,
      oakLumberSlice750OrangeChildVoxelTypes,
      OakLumberSlice750OrangeVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C317504_enterWorld.selector,
        IWorld(world).pretty_C317504_exitWorld.selector,
        IWorld(world).pretty_C317504_variantSelector.selector,
        IWorld(world).pretty_C317504_activate.selector,
        IWorld(world).pretty_C317504_eventHandler.selector,
        IWorld(world).pretty_C317504_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberSlice750OrangeVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberSlice750OrangeVoxelVariantID;
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
