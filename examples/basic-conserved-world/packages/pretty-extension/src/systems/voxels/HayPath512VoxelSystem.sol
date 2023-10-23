// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant HayPath512VoxelID = bytes32(keccak256("hay_path_512"));
bytes32 constant HayPath512VoxelVariantID = bytes32(keccak256("hay_path_512"));

contract HayPath512VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory hayPath512Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, HayPath512VoxelVariantID, hayPath512Variant);

    bytes32[] memory hayPath512ChildVoxelTypes = new bytes32[](1);
    hayPath512ChildVoxelTypes[0] = HayPath512VoxelID;
    bytes32 baseVoxelTypeId = HayPath512VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Hay Path512",
      HayPath512VoxelID,
      baseVoxelTypeId,
      hayPath512ChildVoxelTypes,
      hayPath512ChildVoxelTypes,
      HayPath512VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C35D512_enterWorld.selector,
        IWorld(world).pretty_C35D512_exitWorld.selector,
        IWorld(world).pretty_C35D512_variantSelector.selector,
        IWorld(world).pretty_C35D512_activate.selector,
        IWorld(world).pretty_C35D512_eventHandler.selector,
        IWorld(world).pretty_C35D512_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, HayPath512VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return HayPath512VoxelVariantID;
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
