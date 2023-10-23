// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant GranitePolishedOutset1196VoxelID = bytes32(keccak256("granite_polished_outset_1196"));
bytes32 constant GranitePolishedOutset1196VoxelVariantID = bytes32(keccak256("granite_polished_outset_1196"));

contract GranitePolishedOutset1196VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory granitePolishedOutset1196Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, GranitePolishedOutset1196VoxelVariantID, granitePolishedOutset1196Variant);

    bytes32[] memory granitePolishedOutset1196ChildVoxelTypes = new bytes32[](1);
    granitePolishedOutset1196ChildVoxelTypes[0] = GranitePolishedOutset1196VoxelID;
    bytes32 baseVoxelTypeId = GranitePolishedOutset1196VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Granite Polished Outset1196",
      GranitePolishedOutset1196VoxelID,
      baseVoxelTypeId,
      granitePolishedOutset1196ChildVoxelTypes,
      granitePolishedOutset1196ChildVoxelTypes,
      GranitePolishedOutset1196VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C51D1196_enterWorld.selector,
        IWorld(world).pretty_C51D1196_exitWorld.selector,
        IWorld(world).pretty_C51D1196_variantSelector.selector,
        IWorld(world).pretty_C51D1196_activate.selector,
        IWorld(world).pretty_C51D1196_eventHandler.selector,
        IWorld(world).pretty_C51D1196_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, GranitePolishedOutset1196VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return GranitePolishedOutset1196VoxelVariantID;
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
