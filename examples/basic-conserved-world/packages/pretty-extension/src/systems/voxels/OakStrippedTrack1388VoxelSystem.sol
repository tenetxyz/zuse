// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakStrippedTrack1388VoxelID = bytes32(keccak256("oak_stripped_track_1388"));
bytes32 constant OakStrippedTrack1388VoxelVariantID = bytes32(keccak256("oak_stripped_track_1388"));

contract OakStrippedTrack1388VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakStrippedTrack1388Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakStrippedTrack1388VoxelVariantID, oakStrippedTrack1388Variant);

    bytes32[] memory oakStrippedTrack1388ChildVoxelTypes = new bytes32[](1);
    oakStrippedTrack1388ChildVoxelTypes[0] = OakStrippedTrack1388VoxelID;
    bytes32 baseVoxelTypeId = OakStrippedTrack1388VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Stripped Track1388",
      OakStrippedTrack1388VoxelID,
      baseVoxelTypeId,
      oakStrippedTrack1388ChildVoxelTypes,
      oakStrippedTrack1388ChildVoxelTypes,
      OakStrippedTrack1388VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C73D1388_enterWorld.selector,
        IWorld(world).pretty_C73D1388_exitWorld.selector,
        IWorld(world).pretty_C73D1388_variantSelector.selector,
        IWorld(world).pretty_C73D1388_activate.selector,
        IWorld(world).pretty_C73D1388_eventHandler.selector,
        IWorld(world).pretty_C73D1388_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakStrippedTrack1388VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakStrippedTrack1388VoxelVariantID;
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
