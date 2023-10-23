// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayPolishedWall494VoxelID = bytes32(keccak256("clay_polished_wall_494"));
bytes32 constant ClayPolishedWall494VoxelVariantID = bytes32(keccak256("clay_polished_wall_494"));

contract ClayPolishedWall494VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayPolishedWall494Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayPolishedWall494VoxelVariantID, clayPolishedWall494Variant);

    bytes32[] memory clayPolishedWall494ChildVoxelTypes = new bytes32[](1);
    clayPolishedWall494ChildVoxelTypes[0] = ClayPolishedWall494VoxelID;
    bytes32 baseVoxelTypeId = ClayPolishedWall494VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Polished Wall494",
      ClayPolishedWall494VoxelID,
      baseVoxelTypeId,
      clayPolishedWall494ChildVoxelTypes,
      clayPolishedWall494ChildVoxelTypes,
      ClayPolishedWall494VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C45D494_enterWorld.selector,
        IWorld(world).pretty_C45D494_exitWorld.selector,
        IWorld(world).pretty_C45D494_variantSelector.selector,
        IWorld(world).pretty_C45D494_activate.selector,
        IWorld(world).pretty_C45D494_eventHandler.selector,
        IWorld(world).pretty_C45D494_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayPolishedWall494VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayPolishedWall494VoxelVariantID;
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
