// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SunstoneLog257VoxelID = bytes32(keccak256("sunstone_log_257"));
bytes32 constant SunstoneLog257VoxelVariantID = bytes32(keccak256("sunstone_log_257"));

contract SunstoneLog257VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory sunstoneLog257Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, SunstoneLog257VoxelVariantID, sunstoneLog257Variant);

    bytes32[] memory sunstoneLog257ChildVoxelTypes = new bytes32[](1);
    sunstoneLog257ChildVoxelTypes[0] = SunstoneLog257VoxelID;
    bytes32 baseVoxelTypeId = SunstoneLog257VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Sunstone Log257",
      SunstoneLog257VoxelID,
      baseVoxelTypeId,
      sunstoneLog257ChildVoxelTypes,
      sunstoneLog257ChildVoxelTypes,
      SunstoneLog257VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C66D257_enterWorld.selector,
        IWorld(world).pretty_C66D257_exitWorld.selector,
        IWorld(world).pretty_C66D257_variantSelector.selector,
        IWorld(world).pretty_C66D257_activate.selector,
        IWorld(world).pretty_C66D257_eventHandler.selector,
        IWorld(world).pretty_C66D257_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SunstoneLog257VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SunstoneLog257VoxelVariantID;
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
