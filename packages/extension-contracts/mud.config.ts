import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

const KeysInTableModule_ADDRESS = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9";

export default mudConfig({
  namespace: "extension",
  enums: {
    BlockDirection: ["None", "Up", "Down", "North", "South", "East", "West"],
  },
  tables: {
    Signal: {
      keySchema: {
        namespace: "bytes16",
        entity: "bytes32",
      },
      schema: {
        isActive: "bool",
        direction: "BlockDirection",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    SignalSource: {
      keySchema: {
        namespace: "bytes16",
        entity: "bytes32",
      },
      schema: {
        isNatural: "bool",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    Powered: {
      keySchema: {
        namespace: "bytes16",
        entity: "bytes32",
      },
      schema: {
        isActive: "bool",
        direction: "BlockDirection",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    InvertedSignal: {
      keySchema: {
        namespace: "bytes16",
        entity: "bytes32",
      },
      schema: {
        isActive: "bool",
        direction: "BlockDirection",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    AndGateCR: {
      // AndGate classify result - The key is the creationId
      schema: {
        blockNumber: "uint256", // the blockNumber when the creation passed the classifier
        voxelInterfaces: "bytes",
      },
    },
  },
  modules: [
    // TODO: Re-enable when we have a way to install non-root modules
    // {
    //   name: "KeysInTableModule",
    //   address: KeysInTableModule_ADDRESS,
    //   root: true,
    //   args: [resolveTableId("Signal")],
    // },
    // {
    //   name: "KeysInTableModule",
    //   address: KeysInTableModule_ADDRESS,
    //   root: true,
    //   args: [resolveTableId("SignalSource")],
    // },
    // {
    //   name: "KeysInTableModule",
    //   address: KeysInTableModule_ADDRESS,
    //   root: true,
    //   args: [resolveTableId("Powered")],
    // },
    // {
    //   name: "KeysInTableModule",
    //   address: KeysInTableModule_ADDRESS,
    //   root: true,
    //   args: [resolveTableId("InvertedSignal")],
    // },
  ],
});
