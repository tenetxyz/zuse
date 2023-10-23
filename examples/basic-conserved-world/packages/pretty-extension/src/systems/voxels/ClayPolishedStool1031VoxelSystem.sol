// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayPolishedStool1031VoxelID = bytes32(keccak256("clay_polished_stool_1031"));
bytes32 constant ClayPolishedStool1031VoxelVariantID = bytes32(keccak256("clay_polished_stool_1031"));

contract ClayPolishedStool1031VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayPolishedStool1031Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayPolishedStool1031VoxelVariantID, clayPolishedStool1031Variant);

    bytes32[] memory clayPolishedStool1031ChildVoxelTypes = new bytes32[](1);
    clayPolishedStool1031ChildVoxelTypes[0] = ClayPolishedStool1031VoxelID;
    bytes32 baseVoxelTypeId = ClayPolishedStool1031VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Polished Stool1031",
      ClayPolishedStool1031VoxelID,
      baseVoxelTypeId,
      clayPolishedStool1031ChildVoxelTypes,
      clayPolishedStool1031ChildVoxelTypes,
      ClayPolishedStool1031VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C45D1031_enterWorld.selector,
        IWorld(world).pretty_C45D1031_exitWorld.selector,
        IWorld(world).pretty_C45D1031_variantSelector.selector,
        IWorld(world).pretty_C45D1031_activate.selector,
        IWorld(world).pretty_C45D1031_eventHandler.selector,
        IWorld(world).pretty_C45D1031_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayPolishedStool1031VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayPolishedStool1031VoxelVariantID;
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
