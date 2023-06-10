import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "dhvani",
  tables: {
    Counter: {
      keySchema: {},
      schema: "uint32",
    },
  },
  modules: [],
});
