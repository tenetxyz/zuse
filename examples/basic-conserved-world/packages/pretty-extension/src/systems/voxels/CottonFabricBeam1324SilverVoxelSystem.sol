// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant CottonFabricBeam1324SilverVoxelID = bytes32(keccak256("cotton_fabric_beam_1324_silver"));
bytes32 constant CottonFabricBeam1324SilverVoxelVariantID = bytes32(keccak256("cotton_fabric_beam_1324_silver"));

contract CottonFabricBeam1324SilverVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory cottonFabricBeam1324SilverVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, CottonFabricBeam1324SilverVoxelVariantID, cottonFabricBeam1324SilverVariant);

    bytes32[] memory cottonFabricBeam1324SilverChildVoxelTypes = new bytes32[](1);
    cottonFabricBeam1324SilverChildVoxelTypes[0] = CottonFabricBeam1324SilverVoxelID;
    bytes32 baseVoxelTypeId = CottonFabricBeam1324SilverVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Cotton Fabric Beam1324 Silver",
      CottonFabricBeam1324SilverVoxelID,
      baseVoxelTypeId,
      cottonFabricBeam1324SilverChildVoxelTypes,
      cottonFabricBeam1324SilverChildVoxelTypes,
      CottonFabricBeam1324SilverVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C38D1324E12_enterWorld.selector,
        IWorld(world).pretty_C38D1324E12_exitWorld.selector,
        IWorld(world).pretty_C38D1324E12_variantSelector.selector,
        IWorld(world).pretty_C38D1324E12_activate.selector,
        IWorld(world).pretty_C38D1324E12_eventHandler.selector,
        IWorld(world).pretty_C38D1324E12_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, CottonFabricBeam1324SilverVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return CottonFabricBeam1324SilverVoxelVariantID;
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
