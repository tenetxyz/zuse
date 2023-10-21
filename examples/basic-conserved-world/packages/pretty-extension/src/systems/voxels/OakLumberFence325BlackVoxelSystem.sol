// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberFence325BlackVoxelID = bytes32(keccak256("oak_lumber_fence_325_black"));
bytes32 constant OakLumberFence325BlackVoxelVariantID = bytes32(keccak256("oak_lumber_fence_325_black"));

contract OakLumberFence325BlackVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberFence325BlackVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberFence325BlackVoxelVariantID, oakLumberFence325BlackVariant);

    bytes32[] memory oakLumberFence325BlackChildVoxelTypes = new bytes32[](1);
    oakLumberFence325BlackChildVoxelTypes[0] = OakLumberFence325BlackVoxelID;
    bytes32 baseVoxelTypeId = OakLumberFence325BlackVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Fence325 Black",
      OakLumberFence325BlackVoxelID,
      baseVoxelTypeId,
      oakLumberFence325BlackChildVoxelTypes,
      oakLumberFence325BlackChildVoxelTypes,
      OakLumberFence325BlackVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C313259_enterWorld.selector,
        IWorld(world).pretty_C313259_exitWorld.selector,
        IWorld(world).pretty_C313259_variantSelector.selector,
        IWorld(world).pretty_C313259_activate.selector,
        IWorld(world).pretty_C313259_eventHandler.selector,
        IWorld(world).pretty_C313259_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      5
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberFence325BlackVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberFence325BlackVoxelVariantID;
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
