// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BirchLogFrame645VoxelID = bytes32(keccak256("birch_log_frame_645"));
bytes32 constant BirchLogFrame645VoxelVariantID = bytes32(keccak256("birch_log_frame_645"));

contract BirchLogFrame645VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory birchLogFrame645Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BirchLogFrame645VoxelVariantID, birchLogFrame645Variant);

    bytes32[] memory birchLogFrame645ChildVoxelTypes = new bytes32[](1);
    birchLogFrame645ChildVoxelTypes[0] = BirchLogFrame645VoxelID;
    bytes32 baseVoxelTypeId = BirchLogFrame645VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Birch Log Frame645",
      BirchLogFrame645VoxelID,
      baseVoxelTypeId,
      birchLogFrame645ChildVoxelTypes,
      birchLogFrame645ChildVoxelTypes,
      BirchLogFrame645VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C12D645_enterWorld.selector,
        IWorld(world).pretty_C12D645_exitWorld.selector,
        IWorld(world).pretty_C12D645_variantSelector.selector,
        IWorld(world).pretty_C12D645_activate.selector,
        IWorld(world).pretty_C12D645_eventHandler.selector,
        IWorld(world).pretty_C12D645_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BirchLogFrame645VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BirchLogFrame645VoxelVariantID;
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
