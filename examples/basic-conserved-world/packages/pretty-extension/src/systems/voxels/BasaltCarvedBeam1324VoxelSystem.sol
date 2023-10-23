// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BasaltCarvedBeam1324VoxelID = bytes32(keccak256("basalt_carved_beam_1324"));
bytes32 constant BasaltCarvedBeam1324VoxelVariantID = bytes32(keccak256("basalt_carved_beam_1324"));

contract BasaltCarvedBeam1324VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory basaltCarvedBeam1324Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BasaltCarvedBeam1324VoxelVariantID, basaltCarvedBeam1324Variant);

    bytes32[] memory basaltCarvedBeam1324ChildVoxelTypes = new bytes32[](1);
    basaltCarvedBeam1324ChildVoxelTypes[0] = BasaltCarvedBeam1324VoxelID;
    bytes32 baseVoxelTypeId = BasaltCarvedBeam1324VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Basalt Carved Beam1324",
      BasaltCarvedBeam1324VoxelID,
      baseVoxelTypeId,
      basaltCarvedBeam1324ChildVoxelTypes,
      basaltCarvedBeam1324ChildVoxelTypes,
      BasaltCarvedBeam1324VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C41D1324_enterWorld.selector,
        IWorld(world).pretty_C41D1324_exitWorld.selector,
        IWorld(world).pretty_C41D1324_variantSelector.selector,
        IWorld(world).pretty_C41D1324_activate.selector,
        IWorld(world).pretty_C41D1324_eventHandler.selector,
        IWorld(world).pretty_C41D1324_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BasaltCarvedBeam1324VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BasaltCarvedBeam1324VoxelVariantID;
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
