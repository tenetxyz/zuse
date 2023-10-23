// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CobblestoneSlab169VoxelID = bytes32(keccak256("cobblestone_slab_169"));
bytes32 constant CobblestoneSlab169VoxelVariantID = bytes32(keccak256("cobblestone_slab_169"));

contract CobblestoneSlab169VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cobblestoneSlab169Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CobblestoneSlab169VoxelVariantID, cobblestoneSlab169Variant);

    bytes32[] memory cobblestoneSlab169ChildVoxelTypes = new bytes32[](1);
    cobblestoneSlab169ChildVoxelTypes[0] = CobblestoneSlab169VoxelID;
    bytes32 baseVoxelTypeId = CobblestoneSlab169VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cobblestone Slab169",
      CobblestoneSlab169VoxelID,
      baseVoxelTypeId,
      cobblestoneSlab169ChildVoxelTypes,
      cobblestoneSlab169ChildVoxelTypes,
      CobblestoneSlab169VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C5D169_enterWorld.selector,
        IWorld(world).pretty_C5D169_exitWorld.selector,
        IWorld(world).pretty_C5D169_variantSelector.selector,
        IWorld(world).pretty_C5D169_activate.selector,
        IWorld(world).pretty_C5D169_eventHandler.selector,
        IWorld(world).pretty_C5D169_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CobblestoneSlab169VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CobblestoneSlab169VoxelVariantID;
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
