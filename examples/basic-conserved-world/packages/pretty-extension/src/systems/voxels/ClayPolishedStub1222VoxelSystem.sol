// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pretty-extension/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, CA_ADDRESS } from "@tenet-pretty-extension/src/Constants.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { VoxelCoord, ComponentDef } from "@tenet-utils/src/Types.sol";

bytes32 constant ClayPolishedStub1222VoxelID = bytes32(keccak256("clay_polished_stub_1222"));
bytes32 constant ClayPolishedStub1222VoxelVariantID = bytes32(keccak256("clay_polished_stub_1222"));

contract ClayPolishedStub1222VoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory clayPolishedStub1222Variant;
    registerVoxelVariant(REGISTRY_ADDRESS, ClayPolishedStub1222VoxelVariantID, clayPolishedStub1222Variant);

    bytes32[] memory clayPolishedStub1222ChildVoxelTypes = new bytes32[](1);
    clayPolishedStub1222ChildVoxelTypes[0] = ClayPolishedStub1222VoxelID;
    bytes32 baseVoxelTypeId = ClayPolishedStub1222VoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Clay Polished Stub1222",
      ClayPolishedStub1222VoxelID,
      baseVoxelTypeId,
      clayPolishedStub1222ChildVoxelTypes,
      clayPolishedStub1222ChildVoxelTypes,
      ClayPolishedStub1222VoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).pretty_C45D1222_enterWorld.selector,
        IWorld(world).pretty_C45D1222_exitWorld.selector,
        IWorld(world).pretty_C45D1222_variantSelector.selector,
        IWorld(world).pretty_C45D1222_activate.selector,
        IWorld(world).pretty_C45D1222_eventHandler.selector,
        IWorld(world).pretty_C45D1222_neighbourEventHandler.selector
      ),
      abi.encode(componentDefs),
      1
    );

    registerCAVoxelType(CA_ADDRESS, ClayPolishedStub1222VoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return ClayPolishedStub1222VoxelVariantID;
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
