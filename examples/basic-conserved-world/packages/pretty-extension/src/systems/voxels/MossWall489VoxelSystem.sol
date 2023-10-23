// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant MossWall489VoxelID = bytes32(keccak256("moss_wall_489"));
bytes32 constant MossWall489VoxelVariantID = bytes32(keccak256("moss_wall_489"));

contract MossWall489VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory mossWall489Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, MossWall489VoxelVariantID, mossWall489Variant);

    bytes32[] memory mossWall489ChildVoxelTypes = new bytes32[](1);
    mossWall489ChildVoxelTypes[0] = MossWall489VoxelID;
    bytes32 baseVoxelTypeId = MossWall489VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Moss Wall489",
      MossWall489VoxelID,
      baseVoxelTypeId,
      mossWall489ChildVoxelTypes,
      mossWall489ChildVoxelTypes,
      MossWall489VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C40D489_enterWorld.selector,
        IWorld(world).pretty_C40D489_exitWorld.selector,
        IWorld(world).pretty_C40D489_variantSelector.selector,
        IWorld(world).pretty_C40D489_activate.selector,
        IWorld(world).pretty_C40D489_eventHandler.selector,
        IWorld(world).pretty_C40D489_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, MossWall489VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return MossWall489VoxelVariantID;
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
