// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberFence325GreenVoxelID = bytes32(keccak256("oak_lumber_fence_325_green"));
bytes32 constant OakLumberFence325GreenVoxelVariantID = bytes32(keccak256("oak_lumber_fence_325_green"));

contract OakLumberFence325GreenVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberFence325GreenVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberFence325GreenVoxelVariantID, oakLumberFence325GreenVariant);

    bytes32[] memory oakLumberFence325GreenChildVoxelTypes = new bytes32[](1);
    oakLumberFence325GreenChildVoxelTypes[0] = OakLumberFence325GreenVoxelID;
    bytes32 baseVoxelTypeId = OakLumberFence325GreenVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Fence325 Green",
      OakLumberFence325GreenVoxelID,
      baseVoxelTypeId,
      oakLumberFence325GreenChildVoxelTypes,
      oakLumberFence325GreenChildVoxelTypes,
      OakLumberFence325GreenVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D325E3_enterWorld.selector,
        IWorld(world).pretty_C31D325E3_exitWorld.selector,
        IWorld(world).pretty_C31D325E3_variantSelector.selector,
        IWorld(world).pretty_C31D325E3_activate.selector,
        IWorld(world).pretty_C31D325E3_eventHandler.selector,
        IWorld(world).pretty_C31D325E3_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberFence325GreenVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberFence325GreenVoxelVariantID;
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
