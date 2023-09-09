import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

export default mudConfig({
  namespace: "extension1",
  enums: {
    BlockDirection: ["None", "North", "South", "East", "West", "NorthEast", "NorthWest", "SouthEast", "SouthWest"],
  },
  tables: {
    Signal: {
      keySchema: {
        callerAddress: "address",
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
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        isNatural: "bool",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    Powered: {
      keySchema: {
        callerAddress: "address",
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
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        isActive: "bool",
        direction: "BlockDirection",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    Temperature: {
      keySchema: {
        callerAddress: "address",
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
        callerAddress: "address",
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
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        genRate: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
        sources: "bytes32[]",
        sourceDirections: "bytes", // BlockDirection[]
      },
    },
    PowerWire: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        source: "bytes32",
        destination: "bytes32",
        transferRate: "uint256",
        maxTransferRate: "uint256",
        sourceDirection: "BlockDirection",
        destinationDirection: "BlockDirection",
        lastUpdateBlock: "uint256",
        isBroken: "bool",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    Storage: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        maxStorage: "uint256",
        energyStored: "uint256",
        inRate: "uint256",
        outRate: "uint256",
        source: "bytes32",
        destination: "bytes32",
        sourceDirection: "BlockDirection",
        destinationDirection: "BlockDirection",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
        inBlockHeightUpdate: "bytes", // BlockHeightUpdate
        outBlockHeightUpdate: "bytes", // BlockHeightUpdate
      },
    },
    Consumer: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        source: "bytes32",
        sourceDirection: "BlockDirection",
        inRate: "uint256",
        lastUpdateBlock: "uint256",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    // TODO: Move this to a different level 2 CA
    PowerSignal: {
      keySchema: {
        callerAddress: "address",
        entity: "bytes32",
      },
      schema: {
        isActive: "bool",
        direction: "BlockDirection",
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
      },
    },
    Health: {
      keySchema: {
        entity: "bytes32",
      },
      schema: {
        health: "uint32",
      },
    },
  },
  modules: [],
});
