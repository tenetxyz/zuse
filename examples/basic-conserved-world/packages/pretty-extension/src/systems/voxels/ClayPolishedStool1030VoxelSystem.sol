// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayPolishedStool1030VoxelID = bytes32(keccak256("clay_polished_stool_1030"));
bytes32 constant ClayPolishedStool1030VoxelVariantID = bytes32(keccak256("clay_polished_stool_1030"));

contract ClayPolishedStool1030VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayPolishedStool1030Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayPolishedStool1030VoxelVariantID, clayPolishedStool1030Variant);

    bytes32[] memory clayPolishedStool1030ChildVoxelTypes = new bytes32[](1);
    clayPolishedStool1030ChildVoxelTypes[0] = ClayPolishedStool1030VoxelID;
    bytes32 baseVoxelTypeId = ClayPolishedStool1030VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Polished Stool1030",
      ClayPolishedStool1030VoxelID,
      baseVoxelTypeId,
      clayPolishedStool1030ChildVoxelTypes,
      clayPolishedStool1030ChildVoxelTypes,
      ClayPolishedStool1030VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C45D1030_enterWorld.selector,
        IWorld(world).pretty_C45D1030_exitWorld.selector,
        IWorld(world).pretty_C45D1030_variantSelector.selector,
        IWorld(world).pretty_C45D1030_activate.selector,
        IWorld(world).pretty_C45D1030_eventHandler.selector,
        IWorld(world).pretty_C45D1030_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayPolishedStool1030VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayPolishedStool1030VoxelVariantID;
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
