// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberOutset1196OrangeVoxelID = bytes32(keccak256("oak_lumber_outset_1196_orange"));
bytes32 constant OakLumberOutset1196OrangeVoxelVariantID = bytes32(keccak256("oak_lumber_outset_1196_orange"));

contract OakLumberOutset1196OrangeVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberOutset1196OrangeVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberOutset1196OrangeVoxelVariantID, oakLumberOutset1196OrangeVariant);

    bytes32[] memory oakLumberOutset1196OrangeChildVoxelTypes = new bytes32[](1);
    oakLumberOutset1196OrangeChildVoxelTypes[0] = OakLumberOutset1196OrangeVoxelID;
    bytes32 baseVoxelTypeId = OakLumberOutset1196OrangeVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Outset1196 Orange",
      OakLumberOutset1196OrangeVoxelID,
      baseVoxelTypeId,
      oakLumberOutset1196OrangeChildVoxelTypes,
      oakLumberOutset1196OrangeChildVoxelTypes,
      OakLumberOutset1196OrangeVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C3111964_enterWorld.selector,
        IWorld(world).pretty_C3111964_exitWorld.selector,
        IWorld(world).pretty_C3111964_variantSelector.selector,
        IWorld(world).pretty_C3111964_activate.selector,
        IWorld(world).pretty_C3111964_eventHandler.selector,
        IWorld(world).pretty_C3111964_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberOutset1196OrangeVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberOutset1196OrangeVoxelVariantID;
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
