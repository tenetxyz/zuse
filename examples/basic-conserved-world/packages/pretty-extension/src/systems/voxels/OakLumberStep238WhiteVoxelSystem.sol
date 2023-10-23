// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberStep238WhiteVoxelID = bytes32(keccak256("oak_lumber_step_238_white"));
bytes32 constant OakLumberStep238WhiteVoxelVariantID = bytes32(keccak256("oak_lumber_step_238_white"));

contract OakLumberStep238WhiteVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberStep238WhiteVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberStep238WhiteVoxelVariantID, oakLumberStep238WhiteVariant);

    bytes32[] memory oakLumberStep238WhiteChildVoxelTypes = new bytes32[](1);
    oakLumberStep238WhiteChildVoxelTypes[0] = OakLumberStep238WhiteVoxelID;
    bytes32 baseVoxelTypeId = OakLumberStep238WhiteVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Step238 White",
      OakLumberStep238WhiteVoxelID,
      baseVoxelTypeId,
      oakLumberStep238WhiteChildVoxelTypes,
      oakLumberStep238WhiteChildVoxelTypes,
      OakLumberStep238WhiteVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D238E5_enterWorld.selector,
        IWorld(world).pretty_C31D238E5_exitWorld.selector,
        IWorld(world).pretty_C31D238E5_variantSelector.selector,
        IWorld(world).pretty_C31D238E5_activate.selector,
        IWorld(world).pretty_C31D238E5_eventHandler.selector,
        IWorld(world).pretty_C31D238E5_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberStep238WhiteVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberStep238WhiteVoxelVariantID;
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
