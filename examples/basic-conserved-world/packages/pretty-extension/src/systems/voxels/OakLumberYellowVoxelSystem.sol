// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberYellowVoxelID = bytes32(keccak256("oak_lumber_yellow"));
bytes32 constant OakLumberYellowVoxelVariantID = bytes32(keccak256("oak_lumber_yellow"));

contract OakLumberYellowVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberYellowVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberYellowVoxelVariantID, oakLumberYellowVariant);

    bytes32[] memory oakLumberYellowChildVoxelTypes = new bytes32[](1);
    oakLumberYellowChildVoxelTypes[0] = OakLumberYellowVoxelID;
    bytes32 baseVoxelTypeId = OakLumberYellowVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Yellow",
      OakLumberYellowVoxelID,
      baseVoxelTypeId,
      oakLumberYellowChildVoxelTypes,
      oakLumberYellowChildVoxelTypes,
      OakLumberYellowVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31E8_enterWorld.selector,
        IWorld(world).pretty_C31E8_exitWorld.selector,
        IWorld(world).pretty_C31E8_variantSelector.selector,
        IWorld(world).pretty_C31E8_activate.selector,
        IWorld(world).pretty_C31E8_eventHandler.selector,
        IWorld(world).pretty_C31E8_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberYellowVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberYellowVoxelVariantID;
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
