// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberPeg773OrangeVoxelID = bytes32(keccak256("oak_lumber_peg_773_orange"));
bytes32 constant OakLumberPeg773OrangeVoxelVariantID = bytes32(keccak256("oak_lumber_peg_773_orange"));

contract OakLumberPeg773OrangeVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberPeg773OrangeVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberPeg773OrangeVoxelVariantID, oakLumberPeg773OrangeVariant);

    bytes32[] memory oakLumberPeg773OrangeChildVoxelTypes = new bytes32[](1);
    oakLumberPeg773OrangeChildVoxelTypes[0] = OakLumberPeg773OrangeVoxelID;
    bytes32 baseVoxelTypeId = OakLumberPeg773OrangeVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Peg773 Orange",
      OakLumberPeg773OrangeVoxelID,
      baseVoxelTypeId,
      oakLumberPeg773OrangeChildVoxelTypes,
      oakLumberPeg773OrangeChildVoxelTypes,
      OakLumberPeg773OrangeVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C317734_enterWorld.selector,
        IWorld(world).pretty_C317734_exitWorld.selector,
        IWorld(world).pretty_C317734_variantSelector.selector,
        IWorld(world).pretty_C317734_activate.selector,
        IWorld(world).pretty_C317734_eventHandler.selector,
        IWorld(world).pretty_C317734_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberPeg773OrangeVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberPeg773OrangeVoxelVariantID;
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
