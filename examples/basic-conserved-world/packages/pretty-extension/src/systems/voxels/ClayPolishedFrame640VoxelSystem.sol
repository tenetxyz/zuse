// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayPolishedFrame640VoxelID = bytes32(keccak256("clay_polished_frame_640"));
bytes32 constant ClayPolishedFrame640VoxelVariantID = bytes32(keccak256("clay_polished_frame_640"));

contract ClayPolishedFrame640VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayPolishedFrame640Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayPolishedFrame640VoxelVariantID, clayPolishedFrame640Variant);

    bytes32[] memory clayPolishedFrame640ChildVoxelTypes = new bytes32[](1);
    clayPolishedFrame640ChildVoxelTypes[0] = ClayPolishedFrame640VoxelID;
    bytes32 baseVoxelTypeId = ClayPolishedFrame640VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Polished Frame640",
      ClayPolishedFrame640VoxelID,
      baseVoxelTypeId,
      clayPolishedFrame640ChildVoxelTypes,
      clayPolishedFrame640ChildVoxelTypes,
      ClayPolishedFrame640VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C45D640_enterWorld.selector,
        IWorld(world).pretty_C45D640_exitWorld.selector,
        IWorld(world).pretty_C45D640_variantSelector.selector,
        IWorld(world).pretty_C45D640_activate.selector,
        IWorld(world).pretty_C45D640_eventHandler.selector,
        IWorld(world).pretty_C45D640_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayPolishedFrame640VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayPolishedFrame640VoxelVariantID;
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
