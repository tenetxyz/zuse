import { tenetMudConfig } from "@tenetxyz/base-simulator";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  enums: {
    SimTable: ["None"],
    ValueType: ["Int256"],
  },
  tables: {},
  systems: {},
  modules: [],
});
