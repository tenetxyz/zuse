import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "pokemon",
  enums: {
    BlockDirection: ["None", "North", "South", "East", "West", "Up", "Down"],
  },
  tables: {
    EnergySource: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
  },
  modules: [],
});
