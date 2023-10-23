// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant RubberLumberVoxelID = bytes32(keccak256("rubber_lumber"));
bytes32 constant RubberLumberVoxelVariantID = bytes32(keccak256("rubber_lumber"));

contract RubberLumberVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rubberLumberVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, RubberLumberVoxelVariantID, rubberLumberVariant);

    bytes32[] memory rubberLumberChildVoxelTypes = new bytes32[](1);
    rubberLumberChildVoxelTypes[0] = RubberLumberVoxelID;
    bytes32 baseVoxelTypeId = RubberLumberVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rubber Lumber",
      RubberLumberVoxelID,
      baseVoxelTypeId,
      rubberLumberChildVoxelTypes,
      rubberLumberChildVoxelTypes,
      RubberLumberVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C34_enterWorld.selector,
        IWorld(world).pretty_C34_exitWorld.selector,
        IWorld(world).pretty_C34_variantSelector.selector,
        IWorld(world).pretty_C34_activate.selector,
        IWorld(world).pretty_C34_eventHandler.selector,
        IWorld(world).pretty_C34_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, RubberLumberVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return RubberLumberVoxelVariantID;
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
