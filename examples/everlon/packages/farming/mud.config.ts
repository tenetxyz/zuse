import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "farming",
  enums: {
    // TODO: Add plant stages
    // PlantStage: ["Seed", "Sprout", "Flower"],
    SoilType: ["Protein", "Elixir", "Concentrative", "Diffusive"],
  },
  tables: {
    Soil: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        lastInteractionBlock: "uint256",
        soilType: "SoilType",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    Plant: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        lastInteractionBlock: "uint256",
        totalProduced: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
        consumers: "bytes", // PlantConsumer[]
      },
    },
    Farmer: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        isHungry: "bool",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
  },
  modules: [],
});
