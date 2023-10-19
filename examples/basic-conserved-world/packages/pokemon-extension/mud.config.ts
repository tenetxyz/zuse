import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "pokemon",
  enums: {
    ObjectType: ["None", "Fire", "Water", "Grass"],
    PlantStage: ["Seed", "Sprout", "Flower"],
    EventType: ["None", "SetNPK", "SetNutrients", "SetElixir", "SetProtein", "Die"],
    SoilType: ["ProteinSoil", "ElixirSoil", "Concentrative", "Diffusive"],
  },
  tables: {
    Soil: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        lastEvent: "EventType",
        lastInteractionBlock: "uint256",
        soilType: "SoilType",
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
        lastEvent: "EventType",
        lastInteractionBlock: "uint256",
        totalProduced: "uint256",
        totalConsumed: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
        consumers: "bytes", // PlantConsumer[]
      },
    },
    Pokemon: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        pokemonType: "ObjectType",
        fightingCAEntity: "bytes32",
        isFainted: "bool",
        lastFaintedBlock: "uint256",
        numWins: "uint256",
        numLosses: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    Farmer: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        isHungry: "bool",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
  },
  modules: [],
});
