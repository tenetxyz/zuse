// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant DirtPath556VoxelID = bytes32(keccak256("dirt_path_556"));
bytes32 constant DirtPath556VoxelVariantID = bytes32(keccak256("dirt_path_556"));

contract DirtPath556VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory dirtPath556Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, DirtPath556VoxelVariantID, dirtPath556Variant);

    bytes32[] memory dirtPath556ChildVoxelTypes = new bytes32[](1);
    dirtPath556ChildVoxelTypes[0] = DirtPath556VoxelID;
    bytes32 baseVoxelTypeId = DirtPath556VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Dirt Path556",
      DirtPath556VoxelID,
      baseVoxelTypeId,
      dirtPath556ChildVoxelTypes,
      dirtPath556ChildVoxelTypes,
      DirtPath556VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C2556_enterWorld.selector,
        IWorld(world).pretty_C2556_exitWorld.selector,
        IWorld(world).pretty_C2556_variantSelector.selector,
        IWorld(world).pretty_C2556_activate.selector,
        IWorld(world).pretty_C2556_eventHandler.selector,
        IWorld(world).pretty_C2556_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, DirtPath556VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return DirtPath556VoxelVariantID;
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
