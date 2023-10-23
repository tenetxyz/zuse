// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayPolishedWindow617VoxelID = bytes32(keccak256("clay_polished_window_617"));
bytes32 constant ClayPolishedWindow617VoxelVariantID = bytes32(keccak256("clay_polished_window_617"));

contract ClayPolishedWindow617VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayPolishedWindow617Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayPolishedWindow617VoxelVariantID, clayPolishedWindow617Variant);

    bytes32[] memory clayPolishedWindow617ChildVoxelTypes = new bytes32[](1);
    clayPolishedWindow617ChildVoxelTypes[0] = ClayPolishedWindow617VoxelID;
    bytes32 baseVoxelTypeId = ClayPolishedWindow617VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Polished Window617",
      ClayPolishedWindow617VoxelID,
      baseVoxelTypeId,
      clayPolishedWindow617ChildVoxelTypes,
      clayPolishedWindow617ChildVoxelTypes,
      ClayPolishedWindow617VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C45D617_enterWorld.selector,
        IWorld(world).pretty_C45D617_exitWorld.selector,
        IWorld(world).pretty_C45D617_variantSelector.selector,
        IWorld(world).pretty_C45D617_activate.selector,
        IWorld(world).pretty_C45D617_eventHandler.selector,
        IWorld(world).pretty_C45D617_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayPolishedWindow617VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayPolishedWindow617VoxelVariantID;
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
