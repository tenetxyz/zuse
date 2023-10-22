// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberPeg768OrangeVoxelID = bytes32(keccak256("oak_lumber_peg_768_orange"));
bytes32 constant OakLumberPeg768OrangeVoxelVariantID = bytes32(keccak256("oak_lumber_peg_768_orange"));

contract OakLumberPeg768OrangeVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberPeg768OrangeVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberPeg768OrangeVoxelVariantID, oakLumberPeg768OrangeVariant);

    bytes32[] memory oakLumberPeg768OrangeChildVoxelTypes = new bytes32[](1);
    oakLumberPeg768OrangeChildVoxelTypes[0] = OakLumberPeg768OrangeVoxelID;
    bytes32 baseVoxelTypeId = OakLumberPeg768OrangeVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Peg768 Orange",
      OakLumberPeg768OrangeVoxelID,
      baseVoxelTypeId,
      oakLumberPeg768OrangeChildVoxelTypes,
      oakLumberPeg768OrangeChildVoxelTypes,
      OakLumberPeg768OrangeVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C317684_enterWorld.selector,
        IWorld(world).pretty_C317684_exitWorld.selector,
        IWorld(world).pretty_C317684_variantSelector.selector,
        IWorld(world).pretty_C317684_activate.selector,
        IWorld(world).pretty_C317684_eventHandler.selector,
        IWorld(world).pretty_C317684_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberPeg768OrangeVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberPeg768OrangeVoxelVariantID;
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
