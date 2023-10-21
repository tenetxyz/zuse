// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLogOutset1193VoxelID = bytes32(keccak256("oak_log_outset_1193"));
bytes32 constant OakLogOutset1193VoxelVariantID = bytes32(keccak256("oak_log_outset_1193"));

contract OakLogOutset1193VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLogOutset1193Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLogOutset1193VoxelVariantID, oakLogOutset1193Variant);

    bytes32[] memory oakLogOutset1193ChildVoxelTypes = new bytes32[](1);
    oakLogOutset1193ChildVoxelTypes[0] = OakLogOutset1193VoxelID;
    bytes32 baseVoxelTypeId = OakLogOutset1193VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Log Outset1193",
      OakLogOutset1193VoxelID,
      baseVoxelTypeId,
      oakLogOutset1193ChildVoxelTypes,
      oakLogOutset1193ChildVoxelTypes,
      OakLogOutset1193VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_OakLogOutset1193_enterWorld.selector,
        IWorld(world).pretty_OakLogOutset1193_exitWorld.selector,
        IWorld(world).pretty_OakLogOutset1193_variantSelector.selector,
        IWorld(world).pretty_OakLogOutset1193_activate.selector,
        IWorld(world).pretty_OakLogOutset1193_eventHandler.selector,
        IWorld(world).pretty_OakLogOutset1193_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, OakLogOutset1193VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLogOutset1193VoxelVariantID;
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
