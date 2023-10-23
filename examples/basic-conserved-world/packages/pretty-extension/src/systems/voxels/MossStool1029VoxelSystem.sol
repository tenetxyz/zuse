// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant MossStool1029VoxelID = bytes32(keccak256("moss_stool_1029"));
bytes32 constant MossStool1029VoxelVariantID = bytes32(keccak256("moss_stool_1029"));

contract MossStool1029VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory mossStool1029Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, MossStool1029VoxelVariantID, mossStool1029Variant);

    bytes32[] memory mossStool1029ChildVoxelTypes = new bytes32[](1);
    mossStool1029ChildVoxelTypes[0] = MossStool1029VoxelID;
    bytes32 baseVoxelTypeId = MossStool1029VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Moss Stool1029",
      MossStool1029VoxelID,
      baseVoxelTypeId,
      mossStool1029ChildVoxelTypes,
      mossStool1029ChildVoxelTypes,
      MossStool1029VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C40D1029_enterWorld.selector,
        IWorld(world).pretty_C40D1029_exitWorld.selector,
        IWorld(world).pretty_C40D1029_variantSelector.selector,
        IWorld(world).pretty_C40D1029_activate.selector,
        IWorld(world).pretty_C40D1029_eventHandler.selector,
        IWorld(world).pretty_C40D1029_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, MossStool1029VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return MossStool1029VoxelVariantID;
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
