// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SilverOutset1157VoxelID = bytes32(keccak256("silver_outset_1157"));
bytes32 constant SilverOutset1157VoxelVariantID = bytes32(keccak256("silver_outset_1157"));

contract SilverOutset1157VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory silverOutset1157Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, SilverOutset1157VoxelVariantID, silverOutset1157Variant);

    bytes32[] memory silverOutset1157ChildVoxelTypes = new bytes32[](1);
    silverOutset1157ChildVoxelTypes[0] = SilverOutset1157VoxelID;
    bytes32 baseVoxelTypeId = SilverOutset1157VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Silver Outset1157",
      SilverOutset1157VoxelID,
      baseVoxelTypeId,
      silverOutset1157ChildVoxelTypes,
      silverOutset1157ChildVoxelTypes,
      SilverOutset1157VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C33D1157_enterWorld.selector,
        IWorld(world).pretty_C33D1157_exitWorld.selector,
        IWorld(world).pretty_C33D1157_variantSelector.selector,
        IWorld(world).pretty_C33D1157_activate.selector,
        IWorld(world).pretty_C33D1157_eventHandler.selector,
        IWorld(world).pretty_C33D1157_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SilverOutset1157VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SilverOutset1157VoxelVariantID;
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
