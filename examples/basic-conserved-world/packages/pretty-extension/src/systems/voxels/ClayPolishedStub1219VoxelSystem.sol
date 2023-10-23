// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayPolishedStub1219VoxelID = bytes32(keccak256("clay_polished_stub_1219"));
bytes32 constant ClayPolishedStub1219VoxelVariantID = bytes32(keccak256("clay_polished_stub_1219"));

contract ClayPolishedStub1219VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayPolishedStub1219Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayPolishedStub1219VoxelVariantID, clayPolishedStub1219Variant);

    bytes32[] memory clayPolishedStub1219ChildVoxelTypes = new bytes32[](1);
    clayPolishedStub1219ChildVoxelTypes[0] = ClayPolishedStub1219VoxelID;
    bytes32 baseVoxelTypeId = ClayPolishedStub1219VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Polished Stub1219",
      ClayPolishedStub1219VoxelID,
      baseVoxelTypeId,
      clayPolishedStub1219ChildVoxelTypes,
      clayPolishedStub1219ChildVoxelTypes,
      ClayPolishedStub1219VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C45D1219_enterWorld.selector,
        IWorld(world).pretty_C45D1219_exitWorld.selector,
        IWorld(world).pretty_C45D1219_variantSelector.selector,
        IWorld(world).pretty_C45D1219_activate.selector,
        IWorld(world).pretty_C45D1219_eventHandler.selector,
        IWorld(world).pretty_C45D1219_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayPolishedStub1219VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayPolishedStub1219VoxelVariantID;
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
