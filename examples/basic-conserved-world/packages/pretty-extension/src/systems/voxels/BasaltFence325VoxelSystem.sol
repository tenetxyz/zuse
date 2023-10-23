// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BasaltFence325VoxelID = bytes32(keccak256("basalt_fence_325"));
bytes32 constant BasaltFence325VoxelVariantID = bytes32(keccak256("basalt_fence_325"));

contract BasaltFence325VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory basaltFence325Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BasaltFence325VoxelVariantID, basaltFence325Variant);

    bytes32[] memory basaltFence325ChildVoxelTypes = new bytes32[](1);
    basaltFence325ChildVoxelTypes[0] = BasaltFence325VoxelID;
    bytes32 baseVoxelTypeId = BasaltFence325VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Basalt Fence325",
      BasaltFence325VoxelID,
      baseVoxelTypeId,
      basaltFence325ChildVoxelTypes,
      basaltFence325ChildVoxelTypes,
      BasaltFence325VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C8D325_enterWorld.selector,
        IWorld(world).pretty_C8D325_exitWorld.selector,
        IWorld(world).pretty_C8D325_variantSelector.selector,
        IWorld(world).pretty_C8D325_activate.selector,
        IWorld(world).pretty_C8D325_eventHandler.selector,
        IWorld(world).pretty_C8D325_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BasaltFence325VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BasaltFence325VoxelVariantID;
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
