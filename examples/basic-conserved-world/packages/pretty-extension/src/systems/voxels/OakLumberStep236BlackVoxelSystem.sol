// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberStep236BlackVoxelID = bytes32(keccak256("oak_lumber_step_236_black"));
bytes32 constant OakLumberStep236BlackVoxelVariantID = bytes32(keccak256("oak_lumber_step_236_black"));

contract OakLumberStep236BlackVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberStep236BlackVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberStep236BlackVoxelVariantID, oakLumberStep236BlackVariant);

    bytes32[] memory oakLumberStep236BlackChildVoxelTypes = new bytes32[](1);
    oakLumberStep236BlackChildVoxelTypes[0] = OakLumberStep236BlackVoxelID;
    bytes32 baseVoxelTypeId = OakLumberStep236BlackVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Step236 Black",
      OakLumberStep236BlackVoxelID,
      baseVoxelTypeId,
      oakLumberStep236BlackChildVoxelTypes,
      oakLumberStep236BlackChildVoxelTypes,
      OakLumberStep236BlackVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C312369_enterWorld.selector,
        IWorld(world).pretty_C312369_exitWorld.selector,
        IWorld(world).pretty_C312369_variantSelector.selector,
        IWorld(world).pretty_C312369_activate.selector,
        IWorld(world).pretty_C312369_eventHandler.selector,
        IWorld(world).pretty_C312369_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberStep236BlackVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberStep236BlackVoxelVariantID;
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
