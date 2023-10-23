// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberOutset1193BlackVoxelID = bytes32(keccak256("oak_lumber_outset_1193_black"));
bytes32 constant OakLumberOutset1193BlackVoxelVariantID = bytes32(keccak256("oak_lumber_outset_1193_black"));

contract OakLumberOutset1193BlackVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberOutset1193BlackVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberOutset1193BlackVoxelVariantID, oakLumberOutset1193BlackVariant);

    bytes32[] memory oakLumberOutset1193BlackChildVoxelTypes = new bytes32[](1);
    oakLumberOutset1193BlackChildVoxelTypes[0] = OakLumberOutset1193BlackVoxelID;
    bytes32 baseVoxelTypeId = OakLumberOutset1193BlackVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Outset1193 Black",
      OakLumberOutset1193BlackVoxelID,
      baseVoxelTypeId,
      oakLumberOutset1193BlackChildVoxelTypes,
      oakLumberOutset1193BlackChildVoxelTypes,
      OakLumberOutset1193BlackVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D1193E9_enterWorld.selector,
        IWorld(world).pretty_C31D1193E9_exitWorld.selector,
        IWorld(world).pretty_C31D1193E9_variantSelector.selector,
        IWorld(world).pretty_C31D1193E9_activate.selector,
        IWorld(world).pretty_C31D1193E9_eventHandler.selector,
        IWorld(world).pretty_C31D1193E9_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberOutset1193BlackVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberOutset1193BlackVoxelVariantID;
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
