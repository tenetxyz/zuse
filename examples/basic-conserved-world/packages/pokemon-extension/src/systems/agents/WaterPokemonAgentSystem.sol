// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { AgentType } from "@tenet-base-ca/src/prototypes/AgentType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, WaterPokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { BlockDirection, BodyPhysicsData, CAEventData, CAEventType, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { VoxelCoord, VoxelSelectors, InteractionSelector, ComponentDef, RangeComponent, StateComponent, ComponentType } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";
import { getCAEntityAtCoord, getCAVoxelType } from "@tenet-base-ca/src/Utils.sol";
import { entityIsEnergySource, entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { getVoxelBodyPhysicsFromCaller, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";
import { Pokemon, PokemonData, PokemonMove, PokemonType } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { console } from "forge-std/console.sol";

bytes32 constant PokemonVoxelVariantID = bytes32(keccak256("pokemon-water"));
string constant PokemonTexture = "bafkreihpdljsgdltghxehq4cebngtugfj3pduucijxcrvcla4hoy34f7vq";

contract WaterPokemonAgentSystem is AgentType {
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
    pokemonChildVoxelTypes[0] = WaterPokemonVoxelID;
    bytes32 baseVoxelTypeId = WaterPokemonVoxelID;

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
    string[] memory states = new string[](13);
    states[0] = "None";
    states[1] = "Ember";
    states[2] = "FlameBurst";
    states[3] = "SmokeScreen";
    states[4] = "FireShield";
    states[5] = "WaterGun";
    states[6] = "HydroPump";
    states[7] = "Bubble";
    states[8] = "AquaRing";
    states[9] = "VineWhip";
    states[10] = "SolarBeam";
    states[11] = "LeechSeed";
    states[12] = "Synthesis";
    componentDefs[2] = ComponentDef(ComponentType.STATE, "State", abi.encode(StateComponent(states)));

    registerVoxelType(
      REGISTRY_ADDRESS,
      "Water Pokemon",
      WaterPokemonVoxelID,
      baseVoxelTypeId,
      pokemonChildVoxelTypes,
      pokemonChildVoxelTypes,
      PokemonVoxelVariantID,
      VoxelSelectors({
        enterWorldSelector: IWorld(world).pokemon_WaterPokemonAgen_enterWorld.selector,
        exitWorldSelector: IWorld(world).pokemon_WaterPokemonAgen_exitWorld.selector,
        voxelVariantSelector: IWorld(world).pokemon_WaterPokemonAgen_variantSelector.selector,
        activateSelector: IWorld(world).pokemon_WaterPokemonAgen_activate.selector,
        onNewNeighbourSelector: IWorld(world).pokemon_WaterPokemonAgen_neighbourEventHandler.selector,
        interactionSelectors: getInteractionSelectors()
      }),
      abi.encode(componentDefs)
    );

    registerCAVoxelType(CA_ADDRESS, WaterPokemonVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    bool hasValue = true;
    Pokemon.set(
      callerAddress,
      entity,
      PokemonData({
        lastEnergy: 0,
        health: 0,
        lostHealth: 0,
        stamina: 0,
        lostStamina: 0,
        lastUpdatedBlock: 0,
        round: 0,
        pokemonType: PokemonType.Water,
        move: PokemonMove.None,
        hasValue: hasValue
      })
    );
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
    // TODO: show different variants based on health
    return PokemonVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public override returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_PokemonSystem_neighbourEventHandlerPokemon(
        callerAddress,
        neighbourEntityId,
        centerEntityId,
        PokemonMove.None
      );
  }

  function getInteractionSelectors() public override returns (InteractionSelector[] memory) {
    InteractionSelector[] memory voxelInteractionSelectors = new InteractionSelector[](13);
    voxelInteractionSelectors[0] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_WaterPokemonAgen_replenishEnergyEventHandler.selector,
      interactionName: "Replenish Energy",
      interactionDescription: ""
    });
    voxelInteractionSelectors[1] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_WaterPokemonAgen_emberEventHandler.selector,
      interactionName: "Ember",
      interactionDescription: ""
    });
    voxelInteractionSelectors[2] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_WaterPokemonAgen_flameBurstEventHandler.selector,
      interactionName: "Flame Burst",
      interactionDescription: ""
    });
    voxelInteractionSelectors[3] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_WaterPokemonAgen_smokeScreenEventHandler.selector,
      interactionName: "Smoke Screen",
      interactionDescription: ""
    });
    voxelInteractionSelectors[4] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_WaterPokemonAgen_fireShieldEventHandler.selector,
      interactionName: "Fire Shield",
      interactionDescription: ""
    });
    voxelInteractionSelectors[5] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_WaterPokemonAgen_waterGunEventHandler.selector,
      interactionName: "Water Gun",
      interactionDescription: ""
    });
    voxelInteractionSelectors[6] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_WaterPokemonAgen_hydroPumpEventHandler.selector,
      interactionName: "Hydro Pump",
      interactionDescription: ""
    });
    voxelInteractionSelectors[7] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_WaterPokemonAgen_bubbleEventHandler.selector,
      interactionName: "Bubble",
      interactionDescription: ""
    });
    voxelInteractionSelectors[8] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_WaterPokemonAgen_aquaRingEventHandler.selector,
      interactionName: "Aqua Ring",
      interactionDescription: ""
    });
    voxelInteractionSelectors[9] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_WaterPokemonAgen_vineWhipEventHandler.selector,
      interactionName: "Vine Whip",
      interactionDescription: ""
    });
    voxelInteractionSelectors[10] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_WaterPokemonAgen_solarBeamEventHandler.selector,
      interactionName: "Solar Beam",
      interactionDescription: ""
    });
    voxelInteractionSelectors[11] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_WaterPokemonAgen_leechSeedEventHandler.selector,
      interactionName: "Leech Seed",
      interactionDescription: ""
    });
    voxelInteractionSelectors[12] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_WaterPokemonAgen_synthesisEventHandler.selector,
      interactionName: "Synthesis",
      interactionDescription: ""
    });

    return voxelInteractionSelectors;
  }

  function replenishEnergyEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_PokemonSystem_eventHandlerPokemon(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity,
        PokemonMove.None
      );
  }

  function emberEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_PokemonSystem_eventHandlerPokemon(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity,
        PokemonMove.Ember
      );
  }

  function flameBurstEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_PokemonSystem_eventHandlerPokemon(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity,
        PokemonMove.FlameBurst
      );
  }

  function smokeScreenEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_PokemonSystem_eventHandlerPokemon(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity,
        PokemonMove.SmokeScreen
      );
  }

  function fireShieldEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_PokemonSystem_eventHandlerPokemon(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity,
        PokemonMove.FireShield
      );
  }

  function waterGunEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_PokemonSystem_eventHandlerPokemon(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity,
        PokemonMove.WaterGun
      );
  }

  function hydroPumpEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_PokemonSystem_eventHandlerPokemon(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity,
        PokemonMove.HydroPump
      );
  }

  function bubbleEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_PokemonSystem_eventHandlerPokemon(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity,
        PokemonMove.Bubble
      );
  }

  function aquaRingEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_PokemonSystem_eventHandlerPokemon(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity,
        PokemonMove.AquaRing
      );
  }

  function vineWhipEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_PokemonSystem_eventHandlerPokemon(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity,
        PokemonMove.VineWhip
      );
  }

  function solarBeamEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_PokemonSystem_eventHandlerPokemon(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity,
        PokemonMove.SolarBeam
      );
  }

  function leechSeedEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_PokemonSystem_eventHandlerPokemon(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity,
        PokemonMove.LeechSeed
      );
  }

  function synthesisEventHandler(
    bytes32 centerEntityId,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public returns (bool, bytes memory) {
    address callerAddress = super.getCallerAddress();
    return
      IWorld(_world()).pokemon_PokemonSystem_eventHandlerPokemon(
        callerAddress,
        centerEntityId,
        neighbourEntityIds,
        childEntityIds,
        parentEntity,
        PokemonMove.Synthesis
      );
  }
}
