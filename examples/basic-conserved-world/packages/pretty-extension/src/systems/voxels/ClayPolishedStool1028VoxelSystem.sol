// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayPolishedStool1028VoxelID = bytes32(keccak256("clay_polished_stool_1028"));
bytes32 constant ClayPolishedStool1028VoxelVariantID = bytes32(keccak256("clay_polished_stool_1028"));

contract ClayPolishedStool1028VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayPolishedStool1028Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayPolishedStool1028VoxelVariantID, clayPolishedStool1028Variant);

    bytes32[] memory clayPolishedStool1028ChildVoxelTypes = new bytes32[](1);
    clayPolishedStool1028ChildVoxelTypes[0] = ClayPolishedStool1028VoxelID;
    bytes32 baseVoxelTypeId = ClayPolishedStool1028VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Polished Stool1028",
      ClayPolishedStool1028VoxelID,
      baseVoxelTypeId,
      clayPolishedStool1028ChildVoxelTypes,
      clayPolishedStool1028ChildVoxelTypes,
      ClayPolishedStool1028VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C45D1028_enterWorld.selector,
        IWorld(world).pretty_C45D1028_exitWorld.selector,
        IWorld(world).pretty_C45D1028_variantSelector.selector,
        IWorld(world).pretty_C45D1028_activate.selector,
        IWorld(world).pretty_C45D1028_eventHandler.selector,
        IWorld(world).pretty_C45D1028_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayPolishedStool1028VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayPolishedStool1028VoxelVariantID;
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
