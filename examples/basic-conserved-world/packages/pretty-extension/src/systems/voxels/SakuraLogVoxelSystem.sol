// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SakuraLogVoxelID = bytes32(keccak256("sakura_log"));
bytes32 constant SakuraLogVoxelVariantID = bytes32(keccak256("sakura_log"));

contract SakuraLogVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory sakuraLogVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, SakuraLogVoxelVariantID, sakuraLogVariant);

    bytes32[] memory sakuraLogChildVoxelTypes = new bytes32[](1);
    sakuraLogChildVoxelTypes[0] = SakuraLogVoxelID;
    bytes32 baseVoxelTypeId = SakuraLogVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Sakura Log",
      SakuraLogVoxelID,
      baseVoxelTypeId,
      sakuraLogChildVoxelTypes,
      sakuraLogChildVoxelTypes,
      SakuraLogVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C78_enterWorld.selector,
        IWorld(world).pretty_C78_exitWorld.selector,
        IWorld(world).pretty_C78_variantSelector.selector,
        IWorld(world).pretty_C78_activate.selector,
        IWorld(world).pretty_C78_eventHandler.selector,
        IWorld(world).pretty_C78_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SakuraLogVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SakuraLogVoxelVariantID;
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
