// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberPeg812VoxelID = bytes32(keccak256("oak_lumber_peg_812"));
bytes32 constant OakLumberPeg812VoxelVariantID = bytes32(keccak256("oak_lumber_peg_812"));

contract OakLumberPeg812VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberPeg812Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberPeg812VoxelVariantID, oakLumberPeg812Variant);

    bytes32[] memory oakLumberPeg812ChildVoxelTypes = new bytes32[](1);
    oakLumberPeg812ChildVoxelTypes[0] = OakLumberPeg812VoxelID;
    bytes32 baseVoxelTypeId = OakLumberPeg812VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Peg812",
      OakLumberPeg812VoxelID,
      baseVoxelTypeId,
      oakLumberPeg812ChildVoxelTypes,
      oakLumberPeg812ChildVoxelTypes,
      OakLumberPeg812VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_OakLumberPeg812V_enterWorld.selector,
        IWorld(world).pretty_OakLumberPeg812V_exitWorld.selector,
        IWorld(world).pretty_OakLumberPeg812V_variantSelector.selector,
        IWorld(world).pretty_OakLumberPeg812V_activate.selector,
        IWorld(world).pretty_OakLumberPeg812V_eventHandler.selector,
        IWorld(world).pretty_OakLumberPeg812V_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberPeg812VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberPeg812VoxelVariantID;
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
