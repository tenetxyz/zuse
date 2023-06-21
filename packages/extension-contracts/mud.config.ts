import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "dhvani",
  enums: {
    BlockDirection: [
      "None",
      "Up",
      "Down",
      "North",
      "South",
      "East",
      "West"
    ],
  },
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
        direction: "BlockDirection",
      },
    },
    SignalSource: {
      keySchema: {
        namespace: "bytes16",
        entity: "bytes32",
      },
      schema: {
        isNatural: "bool",
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
