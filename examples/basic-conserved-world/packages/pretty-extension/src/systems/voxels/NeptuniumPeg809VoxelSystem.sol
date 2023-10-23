// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant NeptuniumPeg809VoxelID = bytes32(keccak256("neptunium_peg_809"));
bytes32 constant NeptuniumPeg809VoxelVariantID = bytes32(keccak256("neptunium_peg_809"));

contract NeptuniumPeg809VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory neptuniumPeg809Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, NeptuniumPeg809VoxelVariantID, neptuniumPeg809Variant);

    bytes32[] memory neptuniumPeg809ChildVoxelTypes = new bytes32[](1);
    neptuniumPeg809ChildVoxelTypes[0] = NeptuniumPeg809VoxelID;
    bytes32 baseVoxelTypeId = NeptuniumPeg809VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Neptunium Peg809",
      NeptuniumPeg809VoxelID,
      baseVoxelTypeId,
      neptuniumPeg809ChildVoxelTypes,
      neptuniumPeg809ChildVoxelTypes,
      NeptuniumPeg809VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C28D809_enterWorld.selector,
        IWorld(world).pretty_C28D809_exitWorld.selector,
        IWorld(world).pretty_C28D809_variantSelector.selector,
        IWorld(world).pretty_C28D809_activate.selector,
        IWorld(world).pretty_C28D809_eventHandler.selector,
        IWorld(world).pretty_C28D809_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, NeptuniumPeg809VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return NeptuniumPeg809VoxelVariantID;
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
