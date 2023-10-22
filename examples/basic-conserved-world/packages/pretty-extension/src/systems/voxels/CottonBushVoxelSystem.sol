// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonBushVoxelID = bytes32(keccak256("cotton_bush"));
bytes32 constant CottonBushVoxelVariantID = bytes32(keccak256("cotton_bush"));

contract CottonBushVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonBushVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonBushVoxelVariantID, cottonBushVariant);

    bytes32[] memory cottonBushChildVoxelTypes = new bytes32[](1);
    cottonBushChildVoxelTypes[0] = CottonBushVoxelID;
    bytes32 baseVoxelTypeId = CottonBushVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Bush",
      CottonBushVoxelID,
      baseVoxelTypeId,
      cottonBushChildVoxelTypes,
      cottonBushChildVoxelTypes,
      CottonBushVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C16777227_enterWorld.selector,
        IWorld(world).pretty_C16777227_exitWorld.selector,
        IWorld(world).pretty_C16777227_variantSelector.selector,
        IWorld(world).pretty_C16777227_activate.selector,
        IWorld(world).pretty_C16777227_eventHandler.selector,
        IWorld(world).pretty_C16777227_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonBushVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonBushVoxelVariantID;
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
