// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { AgentType } from "@tenet-base-ca/src/prototypes/AgentType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, PokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { VoxelCoord, VoxelSelectors, InteractionSelector, ComponentDef, RangeComponent, StateComponent, ComponentType } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";
import { getCAEntityAtCoord, getCAVoxelType } from "@tenet-base-ca/src/Utils.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { Pokemon, PokemonMove } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";

bytes32 constant PokemonVoxelVariantID = bytes32(keccak256("pokemon"));
string constant PokemonTexture = "bafkreihpdljsgdltghxehq4cebngtugfj3pduucijxcrvcla4hoy34f7vq";

contract PokemonAgentSystem is AgentType {
  function registerBody() public override {
    address world = _world();
    VoxelVariantsRegistryData memory pokemonVariant;
    pokemonVariant.blockType = NoaBlockType.MESH;
    pokemonVariant.opaque = false;
    pokemonVariant.solid = false;
    pokemonVariant.frames = 1;
    string[] memory pokemonMaterials = new string[](1);
    pokemonMaterials[0] = PokemonTexture;
    pokemonVariant.materials = abi.encode(pokemonMaterials);
    registerVoxelVariant(REGISTRY_ADDRESS, PokemonVoxelVariantID, pokemonVariant);

    bytes32[] memory pokemonChildVoxelTypes = new bytes32[](1);
    pokemonChildVoxelTypes[0] = PokemonVoxelID;
    bytes32 baseVoxelTypeId = PokemonVoxelID;

    ComponentDef[] memory componentDefs = new ComponentDef[](3);
    componentDefs[0] = ComponentDef(
      ComponentType.RANGE,
      "Health",
      abi.encode(RangeComponent({ rangeStart: 0, rangeEnd: 100 }))
    );
    componentDefs[1] = ComponentDef(
      ComponentType.RANGE,
      "Stamina",
      abi.encode(RangeComponent({ rangeStart: 0, rangeEnd: 200 }))
    );
    string[] memory states = new string[](3);
    states[0] = "Running";
    states[1] = "Defending";
    states[2] = "Attacking";
    componentDefs[2] = ComponentDef(ComponentType.STATE, "State", abi.encode(StateComponent(states)));

    registerVoxelType(
      REGISTRY_ADDRESS,
      "Pokemon",
      PokemonVoxelID,
      baseVoxelTypeId,
      pokemonChildVoxelTypes,
      pokemonChildVoxelTypes,
      PokemonVoxelVariantID,
      VoxelSelectors({
        enterWorldSelector: IWorld(world).pokemon_PokemonAgentSyst_enterWorld.selector,
        exitWorldSelector: IWorld(world).pokemon_PokemonAgentSyst_exitWorld.selector,
        voxelVariantSelector: IWorld(world).pokemon_PokemonAgentSyst_variantSelector.selector,
        activateSelector: IWorld(world).pokemon_PokemonAgentSyst_activate.selector,
        onNewNeighbourSelector: IWorld(world).pokemon_PokemonAgentSyst_onNewNeighbour.selector,
        interactionSelectors: getInteractionSelectors()
      }),
      abi.encode(componentDefs)
    );

    registerCAVoxelType(CA_ADDRESS, PokemonVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    bool hasValue = true;
    Pokemon.set(callerAddress, entity, 0, 0, 0, PokemonMove.None, hasValue);
  }

  function exitWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    Pokemon.deleteRecord(callerAddress, entity);
  }

  function variantSelector(
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public view override returns (bytes32) {
    return PokemonVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function onNewNeighbour(bytes32 interactEntity, bytes32 neighbourEntityId) public override {}

  function getInteractionSelectors() public override returns (InteractionSelector[] memory) {
    InteractionSelector[] memory voxelInteractionSelectors = new InteractionSelector[](3);
    voxelInteractionSelectors[0] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_moveForwardEventHandler.selector,
      interactionName: "Move Forward",
      interactionDescription: ""
    });
    // TODO: change the selectors so they point to legit contracts
    voxelInteractionSelectors[1] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_moveForwardEventHandler.selector,
      interactionName: "Attack",
      interactionDescription: ""
    });
    voxelInteractionSelectors[2] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_moveForwardEventHandler.selector,
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
