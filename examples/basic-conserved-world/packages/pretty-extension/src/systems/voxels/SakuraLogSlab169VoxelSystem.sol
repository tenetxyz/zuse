// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SakuraLogSlab169VoxelID = bytes32(keccak256("sakura_log_slab_169"));
bytes32 constant SakuraLogSlab169VoxelVariantID = bytes32(keccak256("sakura_log_slab_169"));

contract SakuraLogSlab169VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory sakuraLogSlab169Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, SakuraLogSlab169VoxelVariantID, sakuraLogSlab169Variant);

    bytes32[] memory sakuraLogSlab169ChildVoxelTypes = new bytes32[](1);
    sakuraLogSlab169ChildVoxelTypes[0] = SakuraLogSlab169VoxelID;
    bytes32 baseVoxelTypeId = SakuraLogSlab169VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Sakura Log Slab169",
      SakuraLogSlab169VoxelID,
      baseVoxelTypeId,
      sakuraLogSlab169ChildVoxelTypes,
      sakuraLogSlab169ChildVoxelTypes,
      SakuraLogSlab169VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C78D169_enterWorld.selector,
        IWorld(world).pretty_C78D169_exitWorld.selector,
        IWorld(world).pretty_C78D169_variantSelector.selector,
        IWorld(world).pretty_C78D169_activate.selector,
        IWorld(world).pretty_C78D169_eventHandler.selector,
        IWorld(world).pretty_C78D169_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SakuraLogSlab169VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SakuraLogSlab169VoxelVariantID;
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
