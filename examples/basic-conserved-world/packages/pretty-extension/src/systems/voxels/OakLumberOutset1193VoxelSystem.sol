// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberOutset1193VoxelID = bytes32(keccak256("oak_lumber_outset_1193"));
bytes32 constant OakLumberOutset1193VoxelVariantID = bytes32(keccak256("oak_lumber_outset_1193"));

contract OakLumberOutset1193VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberOutset1193Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberOutset1193VoxelVariantID, oakLumberOutset1193Variant);

    bytes32[] memory oakLumberOutset1193ChildVoxelTypes = new bytes32[](1);
    oakLumberOutset1193ChildVoxelTypes[0] = OakLumberOutset1193VoxelID;
    bytes32 baseVoxelTypeId = OakLumberOutset1193VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Outset1193",
      OakLumberOutset1193VoxelID,
      baseVoxelTypeId,
      oakLumberOutset1193ChildVoxelTypes,
      oakLumberOutset1193ChildVoxelTypes,
      OakLumberOutset1193VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D1193_enterWorld.selector,
        IWorld(world).pretty_C31D1193_exitWorld.selector,
        IWorld(world).pretty_C31D1193_variantSelector.selector,
        IWorld(world).pretty_C31D1193_activate.selector,
        IWorld(world).pretty_C31D1193_eventHandler.selector,
        IWorld(world).pretty_C31D1193_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberOutset1193VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberOutset1193VoxelVariantID;
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
