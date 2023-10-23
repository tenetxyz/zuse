// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant GranitePolishedVoxelID = bytes32(keccak256("granite_polished"));
bytes32 constant GranitePolishedVoxelVariantID = bytes32(keccak256("granite_polished"));

contract GranitePolishedVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory granitePolishedVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, GranitePolishedVoxelVariantID, granitePolishedVariant);

    bytes32[] memory granitePolishedChildVoxelTypes = new bytes32[](1);
    granitePolishedChildVoxelTypes[0] = GranitePolishedVoxelID;
    bytes32 baseVoxelTypeId = GranitePolishedVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Granite Polished",
      GranitePolishedVoxelID,
      baseVoxelTypeId,
      granitePolishedChildVoxelTypes,
      granitePolishedChildVoxelTypes,
      GranitePolishedVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C51_enterWorld.selector,
        IWorld(world).pretty_C51_exitWorld.selector,
        IWorld(world).pretty_C51_variantSelector.selector,
        IWorld(world).pretty_C51_activate.selector,
        IWorld(world).pretty_C51_eventHandler.selector,
        IWorld(world).pretty_C51_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, GranitePolishedVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return GranitePolishedVoxelVariantID;
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
