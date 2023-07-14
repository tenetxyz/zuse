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
    TwoDirtCR: {
      // TwoDirt classify result - The key is the creationId
      schema: {
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
        blockNumber: "uint256", // the blockNumber when the creation passed the classifier
        displayText: "string",
      },
    },
    AndGateCR: {
      // AndGate classify result - The key is the creationId
      schema: {
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
        blockNumber: "uint256", // the blockNumber when the creation passed the classifier
        displayText: "string",
        voxelInterfaces: "bytes",
      },
    },
    Temperature: {
      keySchema: {
        namespace: "bytes16",
        entity: "bytes32",
      },
      schema: {
        temperature: "uint256",
        lastUpdateBlock: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    TemperatureAtTime: {
      keySchema: {
        namespace: "bytes16",
        entity: "bytes32",
      },
      schema: {
        temperature: "uint256",
        lastUpdateBlock: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    Generator: {
      keySchema: {
        namespace: "bytes16",
        entity: "bytes32",
      },
      schema: {
        genRate: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
        sources: "bytes32[]",
      },
    },
    PowerWire: {
      keySchema: {
        namespace: "bytes16",
        entity: "bytes32",
      },
      schema: {
        source: "bytes32",
        destination: "bytes32",
        transferRate: "uint256",
        maxTransferRate: "uint256",
        direction: "BlockDirection",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    }
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
