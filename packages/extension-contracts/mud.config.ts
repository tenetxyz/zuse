import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "dhvani",
  tables: {
    Powered: {
      keySchema: {
        namespace: "bytes16",
        entity: "bytes32",
      },
      schema: {
        isActive: "bool",
        direction: "uint8",
      },
    },
    Signal: {
      keySchema: {
        namespace: "bytes16",
        entity: "bytes32",
      },
      schema: {
        isActive: "bool",
        direction: "uint8",
      },
    }
  },
  modules: [
    // {
    //   name: "KeysInTableModule",
    //   root: false,
    //   args: [resolveTableId("Powered")],
    // },
  ],
});
