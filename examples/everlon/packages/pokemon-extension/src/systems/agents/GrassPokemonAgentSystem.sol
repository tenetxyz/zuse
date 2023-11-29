// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { AgentType } from "@tenet-base-ca/src/prototypes/AgentType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, GrassPokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { BlockDirection, BodySimData, VoxelCoord, ObjectType } from "@tenet-utils/src/Types.sol";
import { VoxelCoord, VoxelSelectors, InteractionSelector, ComponentDef, RangeComponent, StateComponent, ComponentType } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";
import { getCAEntityAtCoord, getCAVoxelType } from "@tenet-base-ca/src/Utils.sol";
import { entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { getEntitySimData } from "@tenet-level1-ca/src/Utils.sol";
import { Pokemon, PokemonData } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";
import { PokemonMove } from "@tenet-pokemon-extension/src/Types.sol";
import { console } from "forge-std/console.sol";

bytes32 constant PokemonVoxelVariantID = bytes32(keccak256("pokemon-grass"));
string constant PokemonTexture = "bafkreihpdljsgdltghxehq4cebngtugfj3pduucijxcrvcla4hoy34f7vq";

contract GrassPokemonAgentSystem is AgentType {
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
    pokemonChildVoxelTypes[0] = GrassPokemonVoxelID;
    bytes32 baseVoxelTypeId = GrassPokemonVoxelID;

    ComponentDef[] memory componentDefs = new ComponentDef[](0);

    registerVoxelType(
      REGISTRY_ADDRESS,
      "Grass Creature",
      GrassPokemonVoxelID,
      baseVoxelTypeId,
      pokemonChildVoxelTypes,
      pokemonChildVoxelTypes,
      PokemonVoxelVariantID,
      VoxelSelectors({
        enterWorldSelector: IWorld(world).pokemon_GrassPokemonAgen_enterWorld.selector,
        exitWorldSelector: IWorld(world).pokemon_GrassPokemonAgen_exitWorld.selector,
        voxelVariantSelector: IWorld(world).pokemon_GrassPokemonAgen_variantSelector.selector,
        activateSelector: IWorld(world).pokemon_GrassPokemonAgen_activate.selector,
        onNewNeighbourSelector: IWorld(world).pokemon_GrassPokemonAgen_neighbourEventHandler.selector,
        interactionSelectors: getInteractionSelectors()
      }),
      abi.encode(componentDefs),
      10
    );

    registerCAVoxelType(CA_ADDRESS, GrassPokemonVoxelID);
  }

  function enterWorld(VoxelCoord memory coord, bytes32 entity) public override {
    address callerAddress = super.getCallerAddress();
    bool hasValue = true;
    Pokemon.set(
      callerAddress,
      entity,
      PokemonData({
        lastFaintedBlock: 0,
        pokemonType: ObjectType.Grass,
        isFainted: false,
        fightingCAEntity: bytes32(0),
        numWins: 0,
        numLosses: 0,
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
    InteractionSelector[] memory voxelInteractionSelectors = new InteractionSelector[](19);
    voxelInteractionSelectors[0] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_defaultEventHandler.selector,
      interactionName: "Default",
      interactionDescription: ""
    });
    voxelInteractionSelectors[1] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_emberEventHandler.selector,
      interactionName: "Ember",
      interactionDescription: ""
    });
    voxelInteractionSelectors[2] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_flameBurstEventHandler.selector,
      interactionName: "Flame Burst",
      interactionDescription: ""
    });
    voxelInteractionSelectors[3] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_infernoClashEventHandler.selector,
      interactionName: "Inferno Clash",
      interactionDescription: ""
    });
    voxelInteractionSelectors[4] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_smokeScreenEventHandler.selector,
      interactionName: "Smoke Screen",
      interactionDescription: ""
    });
    voxelInteractionSelectors[5] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_fireShieldEventHandler.selector,
      interactionName: "Fire Shield",
      interactionDescription: ""
    });
    voxelInteractionSelectors[6] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_pyroBarrierEventHandler.selector,
      interactionName: "Pyro Barrier",
      interactionDescription: ""
    });
    voxelInteractionSelectors[7] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_waterGunEventHandler.selector,
      interactionName: "Water Gun",
      interactionDescription: ""
    });
    voxelInteractionSelectors[8] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_hydroPumpEventHandler.selector,
      interactionName: "Hydro Pump",
      interactionDescription: ""
    });
    voxelInteractionSelectors[9] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_tidalCrashEventHandler.selector,
      interactionName: "Tidal Crash",
      interactionDescription: ""
    });
    voxelInteractionSelectors[10] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_bubbleEventHandler.selector,
      interactionName: "Bubble",
      interactionDescription: ""
    });
    voxelInteractionSelectors[11] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_aquaRingEventHandler.selector,
      interactionName: "Aqua Ring",
      interactionDescription: ""
    });
    voxelInteractionSelectors[12] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_mistVeilEventHandler.selector,
      interactionName: "Mist Veil",
      interactionDescription: ""
    });
    voxelInteractionSelectors[13] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_vineWhipEventHandler.selector,
      interactionName: "Vine Whip",
      interactionDescription: ""
    });
    voxelInteractionSelectors[14] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_solarBeamEventHandler.selector,
      interactionName: "Solar Beam",
      interactionDescription: ""
    });
    voxelInteractionSelectors[15] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_thornBurstEventHandler.selector,
      interactionName: "Thorn Burst",
      interactionDescription: ""
    });
    voxelInteractionSelectors[16] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_leechSeedEventHandler.selector,
      interactionName: "Leech Seed",
      interactionDescription: ""
    });
    voxelInteractionSelectors[17] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_synthesisEventHandler.selector,
      interactionName: "Synthesis",
      interactionDescription: ""
    });
    voxelInteractionSelectors[18] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_GrassPokemonAgen_verdantGuardEventHandler.selector,
      interactionName: "Verdant Guard",
      interactionDescription: ""
    });

    return voxelInteractionSelectors;
  }

  function defaultEventHandler(
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

  function infernoClashEventHandler(
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
        PokemonMove.InfernoClash
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

  function pyroBarrierEventHandler(
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
        PokemonMove.PyroBarrier
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

  function tidalCrashEventHandler(
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
        PokemonMove.TidalCrash
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

  function mistVeilEventHandler(
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
        PokemonMove.MistVeil
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

  function thornBurstEventHandler(
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
        PokemonMove.ThornBurst
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

  function verdantGuardEventHandler(
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
        PokemonMove.VerdantGuard
      );
  }
}