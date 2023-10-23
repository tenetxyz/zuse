// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant NeptuniumBeam1285VoxelID = bytes32(keccak256("neptunium_beam_1285"));
bytes32 constant NeptuniumBeam1285VoxelVariantID = bytes32(keccak256("neptunium_beam_1285"));

contract NeptuniumBeam1285VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory neptuniumBeam1285Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, NeptuniumBeam1285VoxelVariantID, neptuniumBeam1285Variant);

    bytes32[] memory neptuniumBeam1285ChildVoxelTypes = new bytes32[](1);
    neptuniumBeam1285ChildVoxelTypes[0] = NeptuniumBeam1285VoxelID;
    bytes32 baseVoxelTypeId = NeptuniumBeam1285VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Neptunium Beam1285",
      NeptuniumBeam1285VoxelID,
      baseVoxelTypeId,
      neptuniumBeam1285ChildVoxelTypes,
      neptuniumBeam1285ChildVoxelTypes,
      NeptuniumBeam1285VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C28D1285_enterWorld.selector,
        IWorld(world).pretty_C28D1285_exitWorld.selector,
        IWorld(world).pretty_C28D1285_variantSelector.selector,
        IWorld(world).pretty_C28D1285_activate.selector,
        IWorld(world).pretty_C28D1285_eventHandler.selector,
        IWorld(world).pretty_C28D1285_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, NeptuniumBeam1285VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return NeptuniumBeam1285VoxelVariantID;
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
