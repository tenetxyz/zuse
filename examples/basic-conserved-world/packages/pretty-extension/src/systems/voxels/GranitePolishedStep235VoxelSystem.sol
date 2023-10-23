// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant GranitePolishedStep235VoxelID = bytes32(keccak256("granite_polished_step_235"));
bytes32 constant GranitePolishedStep235VoxelVariantID = bytes32(keccak256("granite_polished_step_235"));

contract GranitePolishedStep235VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory granitePolishedStep235Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, GranitePolishedStep235VoxelVariantID, granitePolishedStep235Variant);

    bytes32[] memory granitePolishedStep235ChildVoxelTypes = new bytes32[](1);
    granitePolishedStep235ChildVoxelTypes[0] = GranitePolishedStep235VoxelID;
    bytes32 baseVoxelTypeId = GranitePolishedStep235VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Granite Polished Step235",
      GranitePolishedStep235VoxelID,
      baseVoxelTypeId,
      granitePolishedStep235ChildVoxelTypes,
      granitePolishedStep235ChildVoxelTypes,
      GranitePolishedStep235VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C51D235_enterWorld.selector,
        IWorld(world).pretty_C51D235_exitWorld.selector,
        IWorld(world).pretty_C51D235_variantSelector.selector,
        IWorld(world).pretty_C51D235_activate.selector,
        IWorld(world).pretty_C51D235_eventHandler.selector,
        IWorld(world).pretty_C51D235_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, GranitePolishedStep235VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return GranitePolishedStep235VoxelVariantID;
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
