// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberFrame681WhiteVoxelID = bytes32(keccak256("oak_lumber_frame_681_white"));
bytes32 constant OakLumberFrame681WhiteVoxelVariantID = bytes32(keccak256("oak_lumber_frame_681_white"));

contract OakLumberFrame681WhiteVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberFrame681WhiteVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberFrame681WhiteVoxelVariantID, oakLumberFrame681WhiteVariant);

    bytes32[] memory oakLumberFrame681WhiteChildVoxelTypes = new bytes32[](1);
    oakLumberFrame681WhiteChildVoxelTypes[0] = OakLumberFrame681WhiteVoxelID;
    bytes32 baseVoxelTypeId = OakLumberFrame681WhiteVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Frame681 White",
      OakLumberFrame681WhiteVoxelID,
      baseVoxelTypeId,
      oakLumberFrame681WhiteChildVoxelTypes,
      oakLumberFrame681WhiteChildVoxelTypes,
      OakLumberFrame681WhiteVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D681E5_enterWorld.selector,
        IWorld(world).pretty_C31D681E5_exitWorld.selector,
        IWorld(world).pretty_C31D681E5_variantSelector.selector,
        IWorld(world).pretty_C31D681E5_activate.selector,
        IWorld(world).pretty_C31D681E5_eventHandler.selector,
        IWorld(world).pretty_C31D681E5_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberFrame681WhiteVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberFrame681WhiteVoxelVariantID;
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
