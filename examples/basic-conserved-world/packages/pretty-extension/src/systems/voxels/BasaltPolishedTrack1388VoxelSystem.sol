// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant BasaltPolishedTrack1388VoxelID = bytes32(keccak256("basalt_polished_track_1388"));
bytes32 constant BasaltPolishedTrack1388VoxelVariantID = bytes32(keccak256("basalt_polished_track_1388"));

contract BasaltPolishedTrack1388VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory basaltPolishedTrack1388Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, BasaltPolishedTrack1388VoxelVariantID, basaltPolishedTrack1388Variant);

    bytes32[] memory basaltPolishedTrack1388ChildVoxelTypes = new bytes32[](1);
    basaltPolishedTrack1388ChildVoxelTypes[0] = BasaltPolishedTrack1388VoxelID;
    bytes32 baseVoxelTypeId = BasaltPolishedTrack1388VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Basalt Polished Track1388",
      BasaltPolishedTrack1388VoxelID,
      baseVoxelTypeId,
      basaltPolishedTrack1388ChildVoxelTypes,
      basaltPolishedTrack1388ChildVoxelTypes,
      BasaltPolishedTrack1388VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C42D1388_enterWorld.selector,
        IWorld(world).pretty_C42D1388_exitWorld.selector,
        IWorld(world).pretty_C42D1388_variantSelector.selector,
        IWorld(world).pretty_C42D1388_activate.selector,
        IWorld(world).pretty_C42D1388_eventHandler.selector,
        IWorld(world).pretty_C42D1388_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, BasaltPolishedTrack1388VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return BasaltPolishedTrack1388VoxelVariantID;
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
