// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CopperPeg809VoxelID = bytes32(keccak256("copper_peg_809"));
bytes32 constant CopperPeg809VoxelVariantID = bytes32(keccak256("copper_peg_809"));

contract CopperPeg809VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory copperPeg809Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, CopperPeg809VoxelVariantID, copperPeg809Variant);

    bytes32[] memory copperPeg809ChildVoxelTypes = new bytes32[](1);
    copperPeg809ChildVoxelTypes[0] = CopperPeg809VoxelID;
    bytes32 baseVoxelTypeId = CopperPeg809VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Copper Peg809",
      CopperPeg809VoxelID,
      baseVoxelTypeId,
      copperPeg809ChildVoxelTypes,
      copperPeg809ChildVoxelTypes,
      CopperPeg809VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C68D809_enterWorld.selector,
        IWorld(world).pretty_C68D809_exitWorld.selector,
        IWorld(world).pretty_C68D809_variantSelector.selector,
        IWorld(world).pretty_C68D809_activate.selector,
        IWorld(world).pretty_C68D809_eventHandler.selector,
        IWorld(world).pretty_C68D809_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CopperPeg809VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CopperPeg809VoxelVariantID;
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
