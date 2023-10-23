// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BasaltShinglesSlice706VoxelID = bytes32(keccak256("basalt_shingles_slice_706"));
bytes32 constant BasaltShinglesSlice706VoxelVariantID = bytes32(keccak256("basalt_shingles_slice_706"));

contract BasaltShinglesSlice706VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory basaltShinglesSlice706Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BasaltShinglesSlice706VoxelVariantID, basaltShinglesSlice706Variant);

    bytes32[] memory basaltShinglesSlice706ChildVoxelTypes = new bytes32[](1);
    basaltShinglesSlice706ChildVoxelTypes[0] = BasaltShinglesSlice706VoxelID;
    bytes32 baseVoxelTypeId = BasaltShinglesSlice706VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Basalt Shingles Slice706",
      BasaltShinglesSlice706VoxelID,
      baseVoxelTypeId,
      basaltShinglesSlice706ChildVoxelTypes,
      basaltShinglesSlice706ChildVoxelTypes,
      BasaltShinglesSlice706VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C43D706_enterWorld.selector,
        IWorld(world).pretty_C43D706_exitWorld.selector,
        IWorld(world).pretty_C43D706_variantSelector.selector,
        IWorld(world).pretty_C43D706_activate.selector,
        IWorld(world).pretty_C43D706_eventHandler.selector,
        IWorld(world).pretty_C43D706_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BasaltShinglesSlice706VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BasaltShinglesSlice706VoxelVariantID;
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
