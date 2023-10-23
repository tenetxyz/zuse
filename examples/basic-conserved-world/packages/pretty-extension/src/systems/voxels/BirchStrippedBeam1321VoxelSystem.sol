// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BirchStrippedBeam1321VoxelID = bytes32(keccak256("birch_stripped_beam_1321"));
bytes32 constant BirchStrippedBeam1321VoxelVariantID = bytes32(keccak256("birch_stripped_beam_1321"));

contract BirchStrippedBeam1321VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory birchStrippedBeam1321Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BirchStrippedBeam1321VoxelVariantID, birchStrippedBeam1321Variant);

    bytes32[] memory birchStrippedBeam1321ChildVoxelTypes = new bytes32[](1);
    birchStrippedBeam1321ChildVoxelTypes[0] = BirchStrippedBeam1321VoxelID;
    bytes32 baseVoxelTypeId = BirchStrippedBeam1321VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Birch Stripped Beam1321",
      BirchStrippedBeam1321VoxelID,
      baseVoxelTypeId,
      birchStrippedBeam1321ChildVoxelTypes,
      birchStrippedBeam1321ChildVoxelTypes,
      BirchStrippedBeam1321VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C71D1321_enterWorld.selector,
        IWorld(world).pretty_C71D1321_exitWorld.selector,
        IWorld(world).pretty_C71D1321_variantSelector.selector,
        IWorld(world).pretty_C71D1321_activate.selector,
        IWorld(world).pretty_C71D1321_eventHandler.selector,
        IWorld(world).pretty_C71D1321_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BirchStrippedBeam1321VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BirchStrippedBeam1321VoxelVariantID;
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
