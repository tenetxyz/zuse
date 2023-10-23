// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant MossOutset1152VoxelID = bytes32(keccak256("moss_outset_1152"));
bytes32 constant MossOutset1152VoxelVariantID = bytes32(keccak256("moss_outset_1152"));

contract MossOutset1152VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory mossOutset1152Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, MossOutset1152VoxelVariantID, mossOutset1152Variant);

    bytes32[] memory mossOutset1152ChildVoxelTypes = new bytes32[](1);
    mossOutset1152ChildVoxelTypes[0] = MossOutset1152VoxelID;
    bytes32 baseVoxelTypeId = MossOutset1152VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Moss Outset1152",
      MossOutset1152VoxelID,
      baseVoxelTypeId,
      mossOutset1152ChildVoxelTypes,
      mossOutset1152ChildVoxelTypes,
      MossOutset1152VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C40D1152_enterWorld.selector,
        IWorld(world).pretty_C40D1152_exitWorld.selector,
        IWorld(world).pretty_C40D1152_variantSelector.selector,
        IWorld(world).pretty_C40D1152_activate.selector,
        IWorld(world).pretty_C40D1152_eventHandler.selector,
        IWorld(world).pretty_C40D1152_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, MossOutset1152VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return MossOutset1152VoxelVariantID;
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
