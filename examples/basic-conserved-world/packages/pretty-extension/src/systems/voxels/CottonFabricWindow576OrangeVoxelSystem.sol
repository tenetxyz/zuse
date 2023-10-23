// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricWindow576OrangeVoxelID = bytes32(keccak256("cotton_fabric_window_576_orange"));
bytes32 constant CottonFabricWindow576OrangeVoxelVariantID = bytes32(keccak256("cotton_fabric_window_576_orange"));

contract CottonFabricWindow576OrangeVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricWindow576OrangeVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricWindow576OrangeVoxelVariantID, cottonFabricWindow576OrangeVariant);

    bytes32[] memory cottonFabricWindow576OrangeChildVoxelTypes = new bytes32[](1);
    cottonFabricWindow576OrangeChildVoxelTypes[0] = CottonFabricWindow576OrangeVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricWindow576OrangeVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Window576 Orange",
      CottonFabricWindow576OrangeVoxelID,
      baseVoxelTypeId,
      cottonFabricWindow576OrangeChildVoxelTypes,
      cottonFabricWindow576OrangeChildVoxelTypes,
      CottonFabricWindow576OrangeVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D576E4_enterWorld.selector,
        IWorld(world).pretty_C38D576E4_exitWorld.selector,
        IWorld(world).pretty_C38D576E4_variantSelector.selector,
        IWorld(world).pretty_C38D576E4_activate.selector,
        IWorld(world).pretty_C38D576E4_eventHandler.selector,
        IWorld(world).pretty_C38D576E4_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricWindow576OrangeVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricWindow576OrangeVoxelVariantID;
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
