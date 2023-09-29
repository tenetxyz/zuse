import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "pokemon",
  enums: {
    PlantStage: ["Seed", "Sprout", "Flower"],
    PokemonMove: [
      "None",
      "Ember",
      "FlameBurst",
      "SmokeScreen",
      "FireShield",
      "WaterGun",
      "HydroPump",
      "Bubble",
      "AquaRing",
      "VineWhip",
      "SolarBeam",
      "LeechSeed",
      "Synthesis",
    ],
    PokemonType: ["Fire", "Water", "Grass"],
  },
  tables: {
    EnergySource: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        lastInteractionBlock: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    Soil: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        lastInteractionBlock: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    Plant: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        stage: "PlantStage",
        lastInteractionBlock: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    Pokemon: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        lastEnergy: "uint256",
        health: "uint256",
        lostHealth: "uint256",
        stamina: "uint256",
        lostStamina: "uint256",
        lastUpdatedBlock: "uint256",
        round: "int32",
        pokemonType: "PokemonType",
        move: "PokemonMove",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
  },
  systems: {
    PokemonFightSystem: {
      name: "PokemonFightSyst",
      openAccess: false,
      accessList: ["PokemonSystem", "FirePokemonAgentSystem", "WaterPokemonAgentSystem", "GrassPokemonAgentSystem"],
    },
  },
  modules: [],
});
