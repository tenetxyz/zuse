// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-level1-ca/src/codegen/world/IWorld.sol";
import { AgentType } from "@tenet-base-ca/src/prototypes/AgentType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, FighterVoxelID } from "@tenet-level1-ca/src/Constants.sol";
import { VoxelCoord, VoxelSelectors, InteractionSelector, ComponentDef, RangeComponent, StateComponent, ComponentType } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";
import { getCAEntityAtCoord, getCAVoxelType } from "@tenet-base-ca/src/Utils.sol";
import { AirVoxelID } from "@tenet-level1-ca/src/Constants.sol";

bytes32 constant FighterVoxelVariantID = bytes32(keccak256("fighter"));
string constant FighterTexture = "bafkreihpdljsgdltghxehq4cebngtugfj3pduucijxcrvcla4hoy34f7vq";

contract FighterAgentSystem is AgentType {
  function registerBody() public override {
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

    bytes32[] memory fighterChildVoxelTypes = new bytes32[](1);
    fighterChildVoxelTypes[0] = FighterVoxelID;
    bytes32 baseVoxelTypeId = FighterVoxelID;

    ComponentDef[] memory componentDefs = new ComponentDef[](0);

    registerVoxelType(
      REGISTRY_ADDRESS,
      "Fighter",
      FighterVoxelID,
      baseVoxelTypeId,
      fighterChildVoxelTypes,
      fighterChildVoxelTypes,
      FighterVoxelVariantID,
      VoxelSelectors({
        enterWorldSelector: IWorld(world).ca_FighterAgentSyst_enterWorld.selector,
        exitWorldSelector: IWorld(world).ca_FighterAgentSyst_exitWorld.selector,
        voxelVariantSelector: IWorld(world).ca_FighterAgentSyst_variantSelector.selector,
        activateSelector: IWorld(world).ca_FighterAgentSyst_activate.selector,
        onNewNeighbourSelector: IWorld(world).ca_FighterAgentSyst_onNewNeighbour.selector,
        interactionSelectors: getInteractionSelectors()
      }),
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
    return FighterVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function onNewNeighbour(bytes32 interactEntity, bytes32 neighbourEntityId) public override {}

  function getInteractionSelectors() public override returns (InteractionSelector[] memory) {
    InteractionSelector[] memory voxelInteractionSelectors = new InteractionSelector[](3);
    voxelInteractionSelectors[0] = InteractionSelector({
      interactionSelector: IWorld(_world()).ca_FighterAgentSyst_moveForwardEventHandler.selector,
      interactionName: "Move Forward",
      interactionDescription: ""
    });
    // TODO: change the selectors so they point to legit contracts
    voxelInteractionSelectors[1] = InteractionSelector({
      interactionSelector: IWorld(_world()).ca_FighterAgentSyst_moveForwardEventHandler.selector,
      interactionName: "Attack",
      interactionDescription: ""
    });
    voxelInteractionSelectors[2] = InteractionSelector({
      interactionSelector: IWorld(_world()).ca_FighterAgentSyst_moveForwardEventHandler.selector,
      interactionName: "Defend",
      interactionDescription: ""
    });
    return voxelInteractionSelectors;
  }

  function moveForwardEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bytes32, bytes32[] memory) {}
}
