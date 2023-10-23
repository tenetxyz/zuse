// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberSlab135BlueVoxelID = bytes32(keccak256("oak_lumber_slab_135_blue"));
bytes32 constant OakLumberSlab135BlueVoxelVariantID = bytes32(keccak256("oak_lumber_slab_135_blue"));

contract OakLumberSlab135BlueVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberSlab135BlueVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberSlab135BlueVoxelVariantID, oakLumberSlab135BlueVariant);

    bytes32[] memory oakLumberSlab135BlueChildVoxelTypes = new bytes32[](1);
    oakLumberSlab135BlueChildVoxelTypes[0] = OakLumberSlab135BlueVoxelID;
    bytes32 baseVoxelTypeId = OakLumberSlab135BlueVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Slab135 Blue",
      OakLumberSlab135BlueVoxelID,
      baseVoxelTypeId,
      oakLumberSlab135BlueChildVoxelTypes,
      oakLumberSlab135BlueChildVoxelTypes,
      OakLumberSlab135BlueVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D135E1_enterWorld.selector,
        IWorld(world).pretty_C31D135E1_exitWorld.selector,
        IWorld(world).pretty_C31D135E1_variantSelector.selector,
        IWorld(world).pretty_C31D135E1_activate.selector,
        IWorld(world).pretty_C31D135E1_eventHandler.selector,
        IWorld(world).pretty_C31D135E1_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberSlab135BlueVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberSlab135BlueVoxelVariantID;
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
