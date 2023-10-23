// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayPolishedSlab133VoxelID = bytes32(keccak256("clay_polished_slab_133"));
bytes32 constant ClayPolishedSlab133VoxelVariantID = bytes32(keccak256("clay_polished_slab_133"));

contract ClayPolishedSlab133VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayPolishedSlab133Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayPolishedSlab133VoxelVariantID, clayPolishedSlab133Variant);

    bytes32[] memory clayPolishedSlab133ChildVoxelTypes = new bytes32[](1);
    clayPolishedSlab133ChildVoxelTypes[0] = ClayPolishedSlab133VoxelID;
    bytes32 baseVoxelTypeId = ClayPolishedSlab133VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Polished Slab133",
      ClayPolishedSlab133VoxelID,
      baseVoxelTypeId,
      clayPolishedSlab133ChildVoxelTypes,
      clayPolishedSlab133ChildVoxelTypes,
      ClayPolishedSlab133VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C45D133_enterWorld.selector,
        IWorld(world).pretty_C45D133_exitWorld.selector,
        IWorld(world).pretty_C45D133_variantSelector.selector,
        IWorld(world).pretty_C45D133_activate.selector,
        IWorld(world).pretty_C45D133_eventHandler.selector,
        IWorld(world).pretty_C45D133_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayPolishedSlab133VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayPolishedSlab133VoxelVariantID;
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
