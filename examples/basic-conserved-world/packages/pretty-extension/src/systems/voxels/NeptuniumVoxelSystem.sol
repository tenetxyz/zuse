// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant NeptuniumVoxelID = bytes32(keccak256("neptunium"));
bytes32 constant NeptuniumVoxelVariantID = bytes32(keccak256("neptunium"));

contract NeptuniumVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory neptuniumVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, NeptuniumVoxelVariantID, neptuniumVariant);

    bytes32[] memory neptuniumChildVoxelTypes = new bytes32[](1);
    neptuniumChildVoxelTypes[0] = NeptuniumVoxelID;
    bytes32 baseVoxelTypeId = NeptuniumVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Neptunium",
      NeptuniumVoxelID,
      baseVoxelTypeId,
      neptuniumChildVoxelTypes,
      neptuniumChildVoxelTypes,
      NeptuniumVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C28_enterWorld.selector,
        IWorld(world).pretty_C28_exitWorld.selector,
        IWorld(world).pretty_C28_variantSelector.selector,
        IWorld(world).pretty_C28_activate.selector,
        IWorld(world).pretty_C28_eventHandler.selector,
        IWorld(world).pretty_C28_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, NeptuniumVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return NeptuniumVoxelVariantID;
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
