// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BasaltShinglesSlab129VoxelID = bytes32(keccak256("basalt_shingles_slab_129"));
bytes32 constant BasaltShinglesSlab129VoxelVariantID = bytes32(keccak256("basalt_shingles_slab_129"));

contract BasaltShinglesSlab129VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory basaltShinglesSlab129Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BasaltShinglesSlab129VoxelVariantID, basaltShinglesSlab129Variant);

    bytes32[] memory basaltShinglesSlab129ChildVoxelTypes = new bytes32[](1);
    basaltShinglesSlab129ChildVoxelTypes[0] = BasaltShinglesSlab129VoxelID;
    bytes32 baseVoxelTypeId = BasaltShinglesSlab129VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Basalt Shingles Slab129",
      BasaltShinglesSlab129VoxelID,
      baseVoxelTypeId,
      basaltShinglesSlab129ChildVoxelTypes,
      basaltShinglesSlab129ChildVoxelTypes,
      BasaltShinglesSlab129VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C43D129_enterWorld.selector,
        IWorld(world).pretty_C43D129_exitWorld.selector,
        IWorld(world).pretty_C43D129_variantSelector.selector,
        IWorld(world).pretty_C43D129_activate.selector,
        IWorld(world).pretty_C43D129_eventHandler.selector,
        IWorld(world).pretty_C43D129_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BasaltShinglesSlab129VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BasaltShinglesSlab129VoxelVariantID;
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
