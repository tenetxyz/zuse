// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SilverBeam1280VoxelID = bytes32(keccak256("silver_beam_1280"));
bytes32 constant SilverBeam1280VoxelVariantID = bytes32(keccak256("silver_beam_1280"));

contract SilverBeam1280VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory silverBeam1280Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, SilverBeam1280VoxelVariantID, silverBeam1280Variant);

    bytes32[] memory silverBeam1280ChildVoxelTypes = new bytes32[](1);
    silverBeam1280ChildVoxelTypes[0] = SilverBeam1280VoxelID;
    bytes32 baseVoxelTypeId = SilverBeam1280VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Silver Beam1280",
      SilverBeam1280VoxelID,
      baseVoxelTypeId,
      silverBeam1280ChildVoxelTypes,
      silverBeam1280ChildVoxelTypes,
      SilverBeam1280VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C33D1280_enterWorld.selector,
        IWorld(world).pretty_C33D1280_exitWorld.selector,
        IWorld(world).pretty_C33D1280_variantSelector.selector,
        IWorld(world).pretty_C33D1280_activate.selector,
        IWorld(world).pretty_C33D1280_eventHandler.selector,
        IWorld(world).pretty_C33D1280_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SilverBeam1280VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SilverBeam1280VoxelVariantID;
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
