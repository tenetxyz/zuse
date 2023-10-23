// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant OakLumberOutset1196BlackVoxelID = bytes32(keccak256("oak_lumber_outset_1196_black"));
bytes32 constant OakLumberOutset1196BlackVoxelVariantID = bytes32(keccak256("oak_lumber_outset_1196_black"));

contract OakLumberOutset1196BlackVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory oakLumberOutset1196BlackVariant;
    registerVoxelVariant(REGISTRY_ADDRESS, OakLumberOutset1196BlackVoxelVariantID, oakLumberOutset1196BlackVariant);

    bytes32[] memory oakLumberOutset1196BlackChildVoxelTypes = new bytes32[](1);
    oakLumberOutset1196BlackChildVoxelTypes[0] = OakLumberOutset1196BlackVoxelID;
    bytes32 baseVoxelTypeId = OakLumberOutset1196BlackVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Oak Lumber Outset1196 Black",
      OakLumberOutset1196BlackVoxelID,
      baseVoxelTypeId,
      oakLumberOutset1196BlackChildVoxelTypes,
      oakLumberOutset1196BlackChildVoxelTypes,
      OakLumberOutset1196BlackVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C31D1196E9_enterWorld.selector,
        IWorld(world).pretty_C31D1196E9_exitWorld.selector,
        IWorld(world).pretty_C31D1196E9_variantSelector.selector,
        IWorld(world).pretty_C31D1196E9_activate.selector,
        IWorld(world).pretty_C31D1196E9_eventHandler.selector,
        IWorld(world).pretty_C31D1196E9_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, OakLumberOutset1196BlackVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return OakLumberOutset1196BlackVoxelVariantID;
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
