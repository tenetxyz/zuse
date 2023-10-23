// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant SakuraLogStep199VoxelID = bytes32(keccak256("sakura_log_step_199"));
bytes32 constant SakuraLogStep199VoxelVariantID = bytes32(keccak256("sakura_log_step_199"));

contract SakuraLogStep199VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory sakuraLogStep199Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, SakuraLogStep199VoxelVariantID, sakuraLogStep199Variant);

    bytes32[] memory sakuraLogStep199ChildVoxelTypes = new bytes32[](1);
    sakuraLogStep199ChildVoxelTypes[0] = SakuraLogStep199VoxelID;
    bytes32 baseVoxelTypeId = SakuraLogStep199VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Sakura Log Step199",
      SakuraLogStep199VoxelID,
      baseVoxelTypeId,
      sakuraLogStep199ChildVoxelTypes,
      sakuraLogStep199ChildVoxelTypes,
      SakuraLogStep199VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C78D199_enterWorld.selector,
        IWorld(world).pretty_C78D199_exitWorld.selector,
        IWorld(world).pretty_C78D199_variantSelector.selector,
        IWorld(world).pretty_C78D199_activate.selector,
        IWorld(world).pretty_C78D199_eventHandler.selector,
        IWorld(world).pretty_C78D199_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, SakuraLogStep199VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return SakuraLogStep199VoxelVariantID;
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
