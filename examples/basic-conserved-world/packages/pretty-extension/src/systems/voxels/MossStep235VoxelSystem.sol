// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant MossStep235VoxelID = bytes32(keccak256("moss_step_235"));
bytes32 constant MossStep235VoxelVariantID = bytes32(keccak256("moss_step_235"));

contract MossStep235VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory mossStep235Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, MossStep235VoxelVariantID, mossStep235Variant);

    bytes32[] memory mossStep235ChildVoxelTypes = new bytes32[](1);
    mossStep235ChildVoxelTypes[0] = MossStep235VoxelID;
    bytes32 baseVoxelTypeId = MossStep235VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Moss Step235",
      MossStep235VoxelID,
      baseVoxelTypeId,
      mossStep235ChildVoxelTypes,
      mossStep235ChildVoxelTypes,
      MossStep235VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C40D235_enterWorld.selector,
        IWorld(world).pretty_C40D235_exitWorld.selector,
        IWorld(world).pretty_C40D235_variantSelector.selector,
        IWorld(world).pretty_C40D235_activate.selector,
        IWorld(world).pretty_C40D235_eventHandler.selector,
        IWorld(world).pretty_C40D235_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, MossStep235VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return MossStep235VoxelVariantID;
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
