// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BirchLogPeg812VoxelID = bytes32(keccak256("birch_log_peg_812"));
bytes32 constant BirchLogPeg812VoxelVariantID = bytes32(keccak256("birch_log_peg_812"));

contract BirchLogPeg812VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory birchLogPeg812Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BirchLogPeg812VoxelVariantID, birchLogPeg812Variant);

    bytes32[] memory birchLogPeg812ChildVoxelTypes = new bytes32[](1);
    birchLogPeg812ChildVoxelTypes[0] = BirchLogPeg812VoxelID;
    bytes32 baseVoxelTypeId = BirchLogPeg812VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Birch Log Peg812",
      BirchLogPeg812VoxelID,
      baseVoxelTypeId,
      birchLogPeg812ChildVoxelTypes,
      birchLogPeg812ChildVoxelTypes,
      BirchLogPeg812VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C12D812_enterWorld.selector,
        IWorld(world).pretty_C12D812_exitWorld.selector,
        IWorld(world).pretty_C12D812_variantSelector.selector,
        IWorld(world).pretty_C12D812_activate.selector,
        IWorld(world).pretty_C12D812_eventHandler.selector,
        IWorld(world).pretty_C12D812_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BirchLogPeg812VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BirchLogPeg812VoxelVariantID;
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
