// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BasaltShinglesCorner832VoxelID = bytes32(keccak256("basalt_shingles_corner_832"));
bytes32 constant BasaltShinglesCorner832VoxelVariantID = bytes32(keccak256("basalt_shingles_corner_832"));

contract BasaltShinglesCorner832VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory basaltShinglesCorner832Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BasaltShinglesCorner832VoxelVariantID, basaltShinglesCorner832Variant);

    bytes32[] memory basaltShinglesCorner832ChildVoxelTypes = new bytes32[](1);
    basaltShinglesCorner832ChildVoxelTypes[0] = BasaltShinglesCorner832VoxelID;
    bytes32 baseVoxelTypeId = BasaltShinglesCorner832VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Basalt Shingles Corner832",
      BasaltShinglesCorner832VoxelID,
      baseVoxelTypeId,
      basaltShinglesCorner832ChildVoxelTypes,
      basaltShinglesCorner832ChildVoxelTypes,
      BasaltShinglesCorner832VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C43D832_enterWorld.selector,
        IWorld(world).pretty_C43D832_exitWorld.selector,
        IWorld(world).pretty_C43D832_variantSelector.selector,
        IWorld(world).pretty_C43D832_activate.selector,
        IWorld(world).pretty_C43D832_eventHandler.selector,
        IWorld(world).pretty_C43D832_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BasaltShinglesCorner832VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BasaltShinglesCorner832VoxelVariantID;
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
