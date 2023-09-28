// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { AgentType } from "@tenet-base-ca/src/prototypes/AgentType.sol";
import { VoxelVariantsRegistryData } from "@tenet-registry/src/codegen/tables/VoxelVariantsRegistry.sol";
import { NoaBlockType } from "@tenet-registry/src/codegen/Types.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { registerVoxelVariant, registerVoxelType } from "@tenet-registry/src/Utils.sol";
import { CA_ADDRESS, REGISTRY_ADDRESS, PokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { BlockDirection, BodyPhysicsData, CAEventData, CAEventType, VoxelCoord } from "@tenet-utils/src/Types.sol";
import { VoxelCoord, VoxelSelectors, InteractionSelector, ComponentDef, RangeComponent, StateComponent, ComponentType } from "@tenet-utils/src/Types.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";
import { getCAEntityAtCoord, getCAVoxelType } from "@tenet-base-ca/src/Utils.sol";
import { entityIsEnergySource, entityIsSoil, entityIsPlant, entityIsPokemon } from "@tenet-pokemon-extension/src/InteractionUtils.sol";
import { registerCAVoxelType } from "@tenet-base-ca/src/CallUtils.sol";
import { getVoxelBodyPhysicsFromCaller, transferEnergy } from "@tenet-level1-ca/src/Utils.sol";
import { Pokemon, PokemonData, PokemonMove, PokemonType } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";

bytes32 constant PokemonVoxelVariantID = bytes32(keccak256("pokemon"));
string constant PokemonTexture = "bafkreihpdljsgdltghxehq4cebngtugfj3pduucijxcrvcla4hoy34f7vq";

struct MoveData {
  uint8 stamina;
  uint8 damage;
  uint8 protection;
  PokemonType moveType;
}

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
        onNewNeighbourSelector: IWorld(world).pokemon_PokemonAgentSyst_neighbourEventHandler.selector,
        interactionSelectors: getInteractionSelectors()
      }),
      abi.encode(componentDefs)
    );

    registerCAVoxelType(CA_ADDRESS, PokemonVoxelID);
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
        pokemonType: PokemonType.Fire,
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
    return PokemonVoxelVariantID;
  }

  function activate(bytes32 entity) public view override returns (string memory) {}

  function neighbourEventHandler(
    bytes32 neighbourEntityId,
    bytes32 centerEntityId
  ) public override returns (bool, bytes memory) {
    MoveData[] memory movesData = new MoveData[](13); // the first value is for PokemonMove.None
    movesData[uint(PokemonMove.Ember)] = MoveData(10, 20, 0, PokemonType.Fire);
    movesData[uint(PokemonMove.FlameBurst)] = MoveData(20, 40, 0, PokemonType.Fire);
    movesData[uint(PokemonMove.SmokeScreen)] = MoveData(5, 0, 10, PokemonType.Fire);
    movesData[uint(PokemonMove.FireShield)] = MoveData(15, 0, 30, PokemonType.Fire);

    movesData[uint(PokemonMove.WaterGun)] = MoveData(10, 20, 0, PokemonType.Water);
    movesData[uint(PokemonMove.HydroPump)] = MoveData(20, 40, 0, PokemonType.Water);
    movesData[uint(PokemonMove.Bubble)] = MoveData(5, 0, 10, PokemonType.Water);
    movesData[uint(PokemonMove.AquaRing)] = MoveData(15, 0, 30, PokemonType.Water);

    movesData[uint(PokemonMove.VineWhip)] = MoveData(10, 20, 0, PokemonType.Grass);
    movesData[uint(PokemonMove.SolarBeam)] = MoveData(20, 40, 0, PokemonType.Grass);
    movesData[uint(PokemonMove.LeechSeed)] = MoveData(5, 0, 10, PokemonType.Grass);
    movesData[uint(PokemonMove.Synthesis)] = MoveData(15, 0, 30, PokemonType.Grass);

    address callerAddress = super.getCallerAddress();
    PokemonData memory pokemonData = Pokemon.get(callerAddress, neighbourEntityId);
    if (entityIsPokemon(callerAddress, centerEntityId)) {
      PokemonData memory neighbourPokemonData = Pokemon.get(callerAddress, centerEntityId);
      if (pokemonData.move != PokemonMove.None && neighbourPokemonData.move != PokemonMove.None) {
        // Calculate damage
        if (pokemonData.lostHealth < pokemonData.health) {
          // Calculae damage

          MoveData memory myMoveData = movesData[uint(pokemonData.move)];
          MoveData memory opponentMoveData = movesData[uint(neighbourPokemonData.move)];

          if (opponentMoveData.damage > 0 && myMoveData.protection > 0) {
            uint256 damage = calculateDamage(myMoveData, opponentMoveData);
            uint256 protection = calculateProtection(myMoveData, opponentMoveData);
            pokemonData.lostHealth += (damage - protection);
          } else if (opponentMoveData.damage > 0) {
            uint256 damage = calculateDamage(myMoveData, opponentMoveData);
            pokemonData.lostHealth += damage;
          }
        }
      }
    }

    Pokemon.set(callerAddress, neighbourEntityId, pokemonData);
  }

  function calculateDamage(
    MoveData memory myMoveData,
    MoveData memory opponentMoveData
  ) internal pure returns (uint256) {
    uint256 damage = myMoveData.damage;
    // TODO: Figure out how to calculate random factor
    uint256 randomFactor = 1;
    uint256 typeMultiplier = getTypeMultiplier(myMoveData.moveType, opponentMoveData.moveType) / 100;
    return damage * typeMultiplier * randomFactor;
  }

  function calculateProtection(
    MoveData memory myMoveData,
    MoveData memory opponentMoveData
  ) internal pure returns (uint256) {
    uint256 protection = myMoveData.protection;
    // TODO: Figure out how to calculate random factor
    uint256 randomFactor = 1;
    uint256 typeMultiplier = getTypeMultiplier(myMoveData.moveType, opponentMoveData.moveType) / 100;
    return protection * typeMultiplier * randomFactor;
  }

  function getTypeMultiplier(PokemonType moveType, PokemonType neighbourPokemonType) internal pure returns (uint256) {
    if (moveType == PokemonType.Fire) {
      if (neighbourPokemonType == PokemonType.Fire) return 100;
      if (neighbourPokemonType == PokemonType.Water) return 50;
      if (neighbourPokemonType == PokemonType.Grass) return 200;
    } else if (moveType == PokemonType.Water) {
      if (neighbourPokemonType == PokemonType.Fire) return 200;
      if (neighbourPokemonType == PokemonType.Water) return 100;
      if (neighbourPokemonType == PokemonType.Grass) return 50;
    } else if (moveType == PokemonType.Grass) {
      if (neighbourPokemonType == PokemonType.Fire) return 50;
      if (neighbourPokemonType == PokemonType.Water) return 200;
      if (neighbourPokemonType == PokemonType.Grass) return 100;
    }
    revert("Invalid move types"); // Revert if none of the valid move types are matched
  }

  function getInteractionSelectors() public override returns (InteractionSelector[] memory) {
    InteractionSelector[] memory voxelInteractionSelectors = new InteractionSelector[](13);
    voxelInteractionSelectors[0] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_replenishEnergyEventHandler.selector,
      interactionName: "Replenish Energy",
      interactionDescription: ""
    });
    voxelInteractionSelectors[1] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_emberEventHandler.selector,
      interactionName: "Ember",
      interactionDescription: ""
    });
    voxelInteractionSelectors[2] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_flameBurstEventHandler.selector,
      interactionName: "Flame Burst",
      interactionDescription: ""
    });
    voxelInteractionSelectors[3] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_smokeScreenEventHandler.selector,
      interactionName: "Smoke Screen",
      interactionDescription: ""
    });
    voxelInteractionSelectors[4] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_fireShieldEventHandler.selector,
      interactionName: "Fire Shield",
      interactionDescription: ""
    });
    voxelInteractionSelectors[5] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_waterGunEventHandler.selector,
      interactionName: "Water Gun",
      interactionDescription: ""
    });
    voxelInteractionSelectors[6] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_hydroPumpEventHandler.selector,
      interactionName: "Hydro Pump",
      interactionDescription: ""
    });
    voxelInteractionSelectors[7] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_bubbleEventHandler.selector,
      interactionName: "Bubble",
      interactionDescription: ""
    });
    voxelInteractionSelectors[8] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_aquaRingEventHandler.selector,
      interactionName: "Aqua Ring",
      interactionDescription: ""
    });
    voxelInteractionSelectors[9] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_vineWhipEventHandler.selector,
      interactionName: "Vine Whip",
      interactionDescription: ""
    });
    voxelInteractionSelectors[10] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_solarBeamEventHandler.selector,
      interactionName: "Solar Beam",
      interactionDescription: ""
    });
    voxelInteractionSelectors[11] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_leechSeedEventHandler.selector,
      interactionName: "Leech Seed",
      interactionDescription: ""
    });
    voxelInteractionSelectors[12] = InteractionSelector({
      interactionSelector: IWorld(_world()).pokemon_PokemonAgentSyst_synthesisEventHandler.selector,
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
