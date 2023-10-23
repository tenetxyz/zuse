// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberLogOutset1196VoxelID = bytes32(keccak256("rubber_log_outset_1196"));
bytes32 constant RubberLogOutset1196VoxelVariantID = bytes32(keccak256("rubber_log_outset_1196"));

contract RubberLogOutset1196VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberLogOutset1196Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberLogOutset1196VoxelVariantID, rubberLogOutset1196Variant);

    bytes32[] memory rubberLogOutset1196ChildVoxelTypes = new bytes32[](1);
    rubberLogOutset1196ChildVoxelTypes[0] = RubberLogOutset1196VoxelID;
    bytes32 baseVoxelTypeId = RubberLogOutset1196VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Log Outset1196",
      RubberLogOutset1196VoxelID,
      baseVoxelTypeId,
      rubberLogOutset1196ChildVoxelTypes,
      rubberLogOutset1196ChildVoxelTypes,
      RubberLogOutset1196VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C14D1196_enterWorld.selector,
        IWorld(world).pretty_C14D1196_exitWorld.selector,
        IWorld(world).pretty_C14D1196_variantSelector.selector,
        IWorld(world).pretty_C14D1196_activate.selector,
        IWorld(world).pretty_C14D1196_eventHandler.selector,
        IWorld(world).pretty_C14D1196_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberLogOutset1196VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberLogOutset1196VoxelVariantID;
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
