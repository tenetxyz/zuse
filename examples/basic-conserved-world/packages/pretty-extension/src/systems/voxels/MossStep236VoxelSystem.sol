// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant MossStep236VoxelID = bytes32(keccak256("moss_step_236"));
bytes32 constant MossStep236VoxelVariantID = bytes32(keccak256("moss_step_236"));

contract MossStep236VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory mossStep236Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, MossStep236VoxelVariantID, mossStep236Variant);

    bytes32[] memory mossStep236ChildVoxelTypes = new bytes32[](1);
    mossStep236ChildVoxelTypes[0] = MossStep236VoxelID;
    bytes32 baseVoxelTypeId = MossStep236VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Moss Step236",
      MossStep236VoxelID,
      baseVoxelTypeId,
      mossStep236ChildVoxelTypes,
      mossStep236ChildVoxelTypes,
      MossStep236VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C40D236_enterWorld.selector,
        IWorld(world).pretty_C40D236_exitWorld.selector,
        IWorld(world).pretty_C40D236_variantSelector.selector,
        IWorld(world).pretty_C40D236_activate.selector,
        IWorld(world).pretty_C40D236_eventHandler.selector,
        IWorld(world).pretty_C40D236_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, MossStep236VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return MossStep236VoxelVariantID;
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
