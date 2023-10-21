// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberBlackVoxelID = bytes32(keccak256("oak_lumber_black"));
bytes32 constant OakLumberBlackVoxelVariantID = bytes32(keccak256("oak_lumber_black"));

contract OakLumberBlackVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberBlackVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberBlackVoxelVariantID, oakLumberBlackVariant);

    bytes32[] memory oakLumberBlackChildVoxelTypes = new bytes32[](1);
    oakLumberBlackChildVoxelTypes[0] = OakLumberBlackVoxelID;
    bytes32 baseVoxelTypeId = OakLumberBlackVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Black",
      OakLumberBlackVoxelID,
      baseVoxelTypeId,
      oakLumberBlackChildVoxelTypes,
      oakLumberBlackChildVoxelTypes,
      OakLumberBlackVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C319_enterWorld.selector,
        IWorld(world).pretty_C319_exitWorld.selector,
        IWorld(world).pretty_C319_variantSelector.selector,
        IWorld(world).pretty_C319_activate.selector,
        IWorld(world).pretty_C319_eventHandler.selector,
        IWorld(world).pretty_C319_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberBlackVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberBlackVoxelVariantID;
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
