// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant MossSlice704VoxelID = bytes32(keccak256("moss_slice_704"));
bytes32 constant MossSlice704VoxelVariantID = bytes32(keccak256("moss_slice_704"));

contract MossSlice704VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory mossSlice704Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, MossSlice704VoxelVariantID, mossSlice704Variant);

    bytes32[] memory mossSlice704ChildVoxelTypes = new bytes32[](1);
    mossSlice704ChildVoxelTypes[0] = MossSlice704VoxelID;
    bytes32 baseVoxelTypeId = MossSlice704VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Moss Slice704",
      MossSlice704VoxelID,
      baseVoxelTypeId,
      mossSlice704ChildVoxelTypes,
      mossSlice704ChildVoxelTypes,
      MossSlice704VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C40D704_enterWorld.selector,
        IWorld(world).pretty_C40D704_exitWorld.selector,
        IWorld(world).pretty_C40D704_variantSelector.selector,
        IWorld(world).pretty_C40D704_activate.selector,
        IWorld(world).pretty_C40D704_eventHandler.selector,
        IWorld(world).pretty_C40D704_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, MossSlice704VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return MossSlice704VoxelVariantID;
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
