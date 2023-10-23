// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberStool1029BlackVoxelID = bytes32(keccak256("oak_lumber_stool_1029_black"));
bytes32 constant OakLumberStool1029BlackVoxelVariantID = bytes32(keccak256("oak_lumber_stool_1029_black"));

contract OakLumberStool1029BlackVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberStool1029BlackVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberStool1029BlackVoxelVariantID, oakLumberStool1029BlackVariant);

    bytes32[] memory oakLumberStool1029BlackChildVoxelTypes = new bytes32[](1);
    oakLumberStool1029BlackChildVoxelTypes[0] = OakLumberStool1029BlackVoxelID;
    bytes32 baseVoxelTypeId = OakLumberStool1029BlackVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Stool1029 Black",
      OakLumberStool1029BlackVoxelID,
      baseVoxelTypeId,
      oakLumberStool1029BlackChildVoxelTypes,
      oakLumberStool1029BlackChildVoxelTypes,
      OakLumberStool1029BlackVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D1029E9_enterWorld.selector,
        IWorld(world).pretty_C31D1029E9_exitWorld.selector,
        IWorld(world).pretty_C31D1029E9_variantSelector.selector,
        IWorld(world).pretty_C31D1029E9_activate.selector,
        IWorld(world).pretty_C31D1029E9_eventHandler.selector,
        IWorld(world).pretty_C31D1029E9_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberStool1029BlackVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberStool1029BlackVoxelVariantID;
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
