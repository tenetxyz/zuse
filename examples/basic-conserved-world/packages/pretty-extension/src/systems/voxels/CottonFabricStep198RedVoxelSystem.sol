// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricStep198RedVoxelID = bytes32(keccak256("cotton_fabric_step_198_red"));
bytes32 constant CottonFabricStep198RedVoxelVariantID = bytes32(keccak256("cotton_fabric_step_198_red"));

contract CottonFabricStep198RedVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricStep198RedVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricStep198RedVoxelVariantID, cottonFabricStep198RedVariant);

    bytes32[] memory cottonFabricStep198RedChildVoxelTypes = new bytes32[](1);
    cottonFabricStep198RedChildVoxelTypes[0] = CottonFabricStep198RedVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricStep198RedVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Step198 Red",
      CottonFabricStep198RedVoxelID,
      baseVoxelTypeId,
      cottonFabricStep198RedChildVoxelTypes,
      cottonFabricStep198RedChildVoxelTypes,
      CottonFabricStep198RedVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D198E2_enterWorld.selector,
        IWorld(world).pretty_C38D198E2_exitWorld.selector,
        IWorld(world).pretty_C38D198E2_variantSelector.selector,
        IWorld(world).pretty_C38D198E2_activate.selector,
        IWorld(world).pretty_C38D198E2_eventHandler.selector,
        IWorld(world).pretty_C38D198E2_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricStep198RedVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricStep198RedVoxelVariantID;
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
