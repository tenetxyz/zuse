import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "creatures",
  enums: {
    ElementType: ["None", "Fire", "Water", "Grass"],
  },
  tables: {
    Creature: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        elementType: "ElementType",
        fightingObjectEntityId: "bytes32",
        isFainted: "bool",
        lastFaintedBlock: "uint256",
        numWins: "uint256",
        numLosses: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    Thermo: {
      keySchema: {
        worldAddress: "address",
        objectEntityId: "bytes32",
      },
      schema: {
        lastInteractionBlock: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
  },
  modules: [],
});
