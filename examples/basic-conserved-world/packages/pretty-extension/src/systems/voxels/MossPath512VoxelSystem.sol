// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant MossPath512VoxelID = bytes32(keccak256("moss_path_512"));
bytes32 constant MossPath512VoxelVariantID = bytes32(keccak256("moss_path_512"));

contract MossPath512VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory mossPath512Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, MossPath512VoxelVariantID, mossPath512Variant);

    bytes32[] memory mossPath512ChildVoxelTypes = new bytes32[](1);
    mossPath512ChildVoxelTypes[0] = MossPath512VoxelID;
    bytes32 baseVoxelTypeId = MossPath512VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Moss Path512",
      MossPath512VoxelID,
      baseVoxelTypeId,
      mossPath512ChildVoxelTypes,
      mossPath512ChildVoxelTypes,
      MossPath512VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C40D512_enterWorld.selector,
        IWorld(world).pretty_C40D512_exitWorld.selector,
        IWorld(world).pretty_C40D512_variantSelector.selector,
        IWorld(world).pretty_C40D512_activate.selector,
        IWorld(world).pretty_C40D512_eventHandler.selector,
        IWorld(world).pretty_C40D512_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, MossPath512VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return MossPath512VoxelVariantID;
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
