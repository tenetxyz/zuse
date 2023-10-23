// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant GraniteShinglesFence325VoxelID = bytes32(keccak256("granite_shingles_fence_325"));
bytes32 constant GraniteShinglesFence325VoxelVariantID = bytes32(keccak256("granite_shingles_fence_325"));

contract GraniteShinglesFence325VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory graniteShinglesFence325Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, GraniteShinglesFence325VoxelVariantID, graniteShinglesFence325Variant);

    bytes32[] memory graniteShinglesFence325ChildVoxelTypes = new bytes32[](1);
    graniteShinglesFence325ChildVoxelTypes[0] = GraniteShinglesFence325VoxelID;
    bytes32 baseVoxelTypeId = GraniteShinglesFence325VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Granite Shingles Fence325",
      GraniteShinglesFence325VoxelID,
      baseVoxelTypeId,
      graniteShinglesFence325ChildVoxelTypes,
      graniteShinglesFence325ChildVoxelTypes,
      GraniteShinglesFence325VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C52D325_enterWorld.selector,
        IWorld(world).pretty_C52D325_exitWorld.selector,
        IWorld(world).pretty_C52D325_variantSelector.selector,
        IWorld(world).pretty_C52D325_activate.selector,
        IWorld(world).pretty_C52D325_eventHandler.selector,
        IWorld(world).pretty_C52D325_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, GraniteShinglesFence325VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return GraniteShinglesFence325VoxelVariantID;
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
