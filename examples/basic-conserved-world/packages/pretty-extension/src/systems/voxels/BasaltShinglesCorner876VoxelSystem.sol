// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BasaltShinglesCorner876VoxelID = bytes32(keccak256("basalt_shingles_corner_876"));
bytes32 constant BasaltShinglesCorner876VoxelVariantID = bytes32(keccak256("basalt_shingles_corner_876"));

contract BasaltShinglesCorner876VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory basaltShinglesCorner876Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BasaltShinglesCorner876VoxelVariantID, basaltShinglesCorner876Variant);

    bytes32[] memory basaltShinglesCorner876ChildVoxelTypes = new bytes32[](1);
    basaltShinglesCorner876ChildVoxelTypes[0] = BasaltShinglesCorner876VoxelID;
    bytes32 baseVoxelTypeId = BasaltShinglesCorner876VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Basalt Shingles Corner876",
      BasaltShinglesCorner876VoxelID,
      baseVoxelTypeId,
      basaltShinglesCorner876ChildVoxelTypes,
      basaltShinglesCorner876ChildVoxelTypes,
      BasaltShinglesCorner876VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C43D876_enterWorld.selector,
        IWorld(world).pretty_C43D876_exitWorld.selector,
        IWorld(world).pretty_C43D876_variantSelector.selector,
        IWorld(world).pretty_C43D876_activate.selector,
        IWorld(world).pretty_C43D876_eventHandler.selector,
        IWorld(world).pretty_C43D876_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BasaltShinglesCorner876VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BasaltShinglesCorner876VoxelVariantID;
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
