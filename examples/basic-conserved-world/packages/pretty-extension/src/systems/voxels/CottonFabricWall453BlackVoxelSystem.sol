// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricWall453BlackVoxelID = bytes32(keccak256("cotton_fabric_wall_453_black"));
bytes32 constant CottonFabricWall453BlackVoxelVariantID = bytes32(keccak256("cotton_fabric_wall_453_black"));

contract CottonFabricWall453BlackVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricWall453BlackVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricWall453BlackVoxelVariantID, cottonFabricWall453BlackVariant);

    bytes32[] memory cottonFabricWall453BlackChildVoxelTypes = new bytes32[](1);
    cottonFabricWall453BlackChildVoxelTypes[0] = CottonFabricWall453BlackVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricWall453BlackVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Wall453 Black",
      CottonFabricWall453BlackVoxelID,
      baseVoxelTypeId,
      cottonFabricWall453BlackChildVoxelTypes,
      cottonFabricWall453BlackChildVoxelTypes,
      CottonFabricWall453BlackVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D453E9_enterWorld.selector,
        IWorld(world).pretty_C38D453E9_exitWorld.selector,
        IWorld(world).pretty_C38D453E9_variantSelector.selector,
        IWorld(world).pretty_C38D453E9_activate.selector,
        IWorld(world).pretty_C38D453E9_eventHandler.selector,
        IWorld(world).pretty_C38D453E9_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricWall453BlackVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricWall453BlackVoxelVariantID;
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
