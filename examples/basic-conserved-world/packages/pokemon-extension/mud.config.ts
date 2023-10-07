import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "pokemon",
  enums: {
    PlantStage: ["Seed", "Sprout", "Flower"],
    ObjectType: ["None", "Fire", "Water", "Grass"],
  },
  tables: {
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
        lastFaintedBlock: "uint256",
        pokemonType: "ObjectType",
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
