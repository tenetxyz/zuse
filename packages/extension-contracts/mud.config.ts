import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "tenet", // TODO: Make different namespace once we have non-root modules working
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
    {
      name: "KeysInTableModule",
      address: "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9",
      root: true,
      args: [resolveTableId("Signal")],
    },
    {
      name: "KeysInTableModule",
      address: "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9",
      root: true,
      args: [resolveTableId("SignalSource")],
    },
  ],
});
