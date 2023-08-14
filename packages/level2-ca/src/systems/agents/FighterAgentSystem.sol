// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-level2-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForVoxel } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, FighterVoxelID } from "@tenet-level2-ca/src/Constants.sol";
import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";
import { getCAEntityAtCoord, getCAVoxelType } from "@tenet-base-ca/src/Utils.sol";
import { AirVoxelID } from "@tenet-base-ca/src/Constants.sol";
import { console } from "forge-std/console.sol";

bytes32 constant FighterVoxelVariantID = bytes32(keccak256("fighter"));
string constant FighterTexture = "bafkreihpdljsgdltghxehq4cebngtugfj3pduucijxcrvcla4hoy34f7vq";

contract FighterAgentSystem is VoxelType {
  function registerVoxel() public override {
    address world = _world();
    VoxelVariantsRegistryData memory fighterVariant;
    fighterVariant.blockType = NoaBlockType.MESH;
    fighterVariant.opaque = false;
    fighterVariant.solid = false;
    fighterVariant.frames = 1;
    string[] memory fighterMaterials = new string[](1);
    fighterMaterials[0] = FighterTexture;
    fighterVariant.materials = abi.encode(fighterMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, FighterVoxelVariantID, fighterVariant);

    bytes32[] memory fighterChildVoxelTypes = new bytes32[](8);
    for (uint i = 0; i < 8; i++) {
      fighterChildVoxelTypes[i] = AirVoxelID;
    }
    bytes32 baseVoxelTypeId = FighterVoxelID;
    console.log("Fighter");
    console.logBytes4(IWorld(world).ca_FighterAgentSyst_eventHandler.selector);
    registerVoxelType(
      REGISTRY_ADDRESS,
      "Fighter",
      FighterVoxelID,
      baseVoxelTypeId,
      fighterChildVoxelTypes,
      fighterChildVoxelTypes,
      FighterVoxelVariantID,
      voxelSelectorsForVoxel(
        IWorld(world).ca_FighterAgentSyst_enterWorld.selector,
        IWorld(world).ca_FighterAgentSyst_exitWorld.selector,
        IWorld(world).ca_FighterAgentSyst_variantSelector.selector,
        IWorld(world).ca_FighterAgentSyst_activate.selector,
        IWorld(world).ca_FighterAgentSyst_eventHandler.selector
      )
    );
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {}

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return FighterVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32, bytes32[] memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).ca_MoveForwardSyste_eventHandlerMoveForward(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity
      );
  }
}
