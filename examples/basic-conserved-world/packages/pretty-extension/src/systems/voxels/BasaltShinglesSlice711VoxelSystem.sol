// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BasaltShinglesSlice711VoxelID = bytes32(keccak256("basalt_shingles_slice_711"));
bytes32 constant BasaltShinglesSlice711VoxelVariantID = bytes32(keccak256("basalt_shingles_slice_711"));

contract BasaltShinglesSlice711VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory basaltShinglesSlice711Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BasaltShinglesSlice711VoxelVariantID, basaltShinglesSlice711Variant);

    bytes32[] memory basaltShinglesSlice711ChildVoxelTypes = new bytes32[](1);
    basaltShinglesSlice711ChildVoxelTypes[0] = BasaltShinglesSlice711VoxelID;
    bytes32 baseVoxelTypeId = BasaltShinglesSlice711VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Basalt Shingles Slice711",
      BasaltShinglesSlice711VoxelID,
      baseVoxelTypeId,
      basaltShinglesSlice711ChildVoxelTypes,
      basaltShinglesSlice711ChildVoxelTypes,
      BasaltShinglesSlice711VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C43D711_enterWorld.selector,
        IWorld(world).pretty_C43D711_exitWorld.selector,
        IWorld(world).pretty_C43D711_variantSelector.selector,
        IWorld(world).pretty_C43D711_activate.selector,
        IWorld(world).pretty_C43D711_eventHandler.selector,
        IWorld(world).pretty_C43D711_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BasaltShinglesSlice711VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BasaltShinglesSlice711VoxelVariantID;
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
