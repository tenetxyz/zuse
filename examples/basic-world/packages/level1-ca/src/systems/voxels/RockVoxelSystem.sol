// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { VoxelType } from "@tenet-base-ca/src/prototypes/VoxelType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { registerVoxelVariant, registerVoxelType, voxelSelectorsForAgent } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, RockVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { VoxelCoord, ComponentDef, InteractionSelector } from "@tenet-utils/src/Types.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";

bytes32 constant RockVoxelVariantID = bytes32(keccak256("rock"));
string constant RockTexture = "bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a";
string constant RockUVWrap = "bafkreihdit6glam7sreijo7itbs7uwc2ltfeuvcfaublxf6rjo24hf6t4y";

contract RockVoxelSystem is VoxelType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory rockVariant;
    rockVariant.blockType = NoaBlockType.BLOCK;
    rockVariant.opaque = true;
    rockVariant.solid = true;
    string[] memory rockMaterials = new string[](1);
    rockMaterials[0] = RockTexture;
    rockVariant.materials = abi.encode(rockMaterials);
    rockVariant.uvWrap = RockUVWrap;
    registerVoxelVariant(REGISTRY_ADDRESS, RockVoxelVariantID, rockVariant);

    bytes32[] memory rockChildVoxelTypes = new bytes32[](1);
    rockChildVoxelTypes[0] = RockVoxelID;
    bytes32 baseVoxelTypeId = RockVoxelID;
    ComponentDef[] memory componentDefs = new ComponentDef[](0);

    InteractionSelector[] memory interactionSelectors = new InteractionSelector[](2);
    interactionSelectors[0] = InteractionSelector(
      IWorld(world).ca_RockVoxelSystem_eventHandler.selector,
      "fight",
      "u fite!"
    );
    interactionSelectors[1] = InteractionSelector(
      IWorld(world).ca_RockVoxelSystem_eventHandler.selector,
      "defend",
      "u cross arms!"
    );

    registerVoxelType(
      REGISTRY_ADDRESS,
      "Rock",
      RockVoxelID,
      baseVoxelTypeId,
      rockChildVoxelTypes,
      rockChildVoxelTypes,
      RockVoxelVariantID,
      voxelSelectorsForAgent(
        IWorld(world).ca_RockVoxelSystem_enterWorld.selector,
        IWorld(world).ca_RockVoxelSystem_exitWorld.selector,
        IWorld(world).ca_RockVoxelSystem_variantSelector.selector,
        IWorld(world).ca_RockVoxelSystem_activate.selector,
        interactionSelectors
      ),
      abi.encode(componentDefs)
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
    return RockVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function eventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes32, bytes32[] memory) {}
}
